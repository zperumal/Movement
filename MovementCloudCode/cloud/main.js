// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
 
var Flight = Parse.Object.extend("Flight");
Parse.Cloud.beforeSave("Flight", function(request, response) {
  Parse.Cloud.useMasterKey() ;
   var query  = new Parse.Query(Flight);
   query.equalTo("startDate", request.object.get("startDate"));
   query.equalTo("endDate" , request.object.get("endDate"));
   query.equalTo("User", request.object.get("User"));
   query.first({
      success: function(object) {
        if (object) {
          response.error("Record already exists");
        } else {
          response.success();
        }
      },
      error: function(error) {
        response.error("Could not validate uniqueness for this record.");
      }
    });
   
  
});
 
var Distance = Parse.Object.extend("Distance");
Parse.Cloud.beforeSave("Distance", function(request, response) {
  Parse.Cloud.useMasterKey() ;
   var query  = new Parse.Query(Distance);
   query.equalTo("startDate", request.object.get("startDate"));
   query.equalTo("endDate" , request.object.get("endDate"));
   query.equalTo("User", request.object.get("User"));
   query.first({
      success: function(object) {
        if (object) {
          response.error("Record already exists");
        } else {
          response.success();
        }
      },
      error: function(error) {
        response.error("Could not validate uniqueness for this record.");
      }
    });
   
  
});
 
 var Step = Parse.Object.extend("Step");
Parse.Cloud.beforeSave("Step", function(request, response) {
  Parse.Cloud.useMasterKey() ;
   var query  = new Parse.Query(Step);
   query.equalTo("startDate", request.object.get("startDate"));
   query.equalTo("endDate" , request.object.get("endDate"));
   query.equalTo("User", request.object.get("User"));
   query.first({
      success: function(object) {
        if (object) {
          response.error("Record already exists");
        } else {
          response.success();
        }
      },
      error: function(error) {
        response.error("Could not validate uniqueness for this record.");
      }
    });
   
  
});
 
 
 
var  user = Parse.User.extend("User");
Parse.Cloud.beforeSave("User", function(request, response) {
  Parse.Cloud.useMasterKey() ;
  Parse.Cloud.run('jobUpdateStepLeaderboard', {});   
  
});
 

Parse.Cloud.define("getLeaderboard" , function(request, response) {
   
  var query = new Parse.Query(user);
  query.descending("posts");
  query.limit(5);
  query.find({
    success : function(results){
        var list = [];
        for (i = 0; i < results.length; i++)
        {
          json = results[i].toJSON();
          for (var key in json){
            if(key!="username" && key!="posts"){
              delete json[key];
            }
          }
          list[i] = json;
        }
        response.success(list);
      },
      error: function(error)
      {
        response.error("fail");
      }
     
  });
});



 
Parse.Cloud.define("getStepLeaderboard" , function(request, response) {
   
   var query = new Parse.Query(user);
  query.descending("posts");
  query.limit(5);
  query.find({
    success : function(results){
        var list = [];
        for (i = 0; i < results.length; i++)
        {
          json = results[i].toJSON();
          for (var key in json){
            if(key!="username" && key!="weeklySteps"){
              delete json[key];
            }
          }
          list[i] = json;
        }
        response.success(list);
      },
      error: function(error)
      {
        response.error("fail");
      }
     
  });
 
});
 

 
 Parse.Cloud.job("jobUpdateStepLeaderboard", function(request,response) {
  Parse.Cloud.useMasterKey();
  var query = new Parse.Query(Parse.User);   // Query for all users   
  var lastSunday = getLastSunday(new Date());
  var nextSunday = getNextSunday(new Date());
  console.log(lastSunday);
  console.log(nextSunday);
  query.each(function(user) {

    var promise = Parse.Promise.as();

    promise = promise.then(function() {
        // return a promise that will be resolved 
        var stepQuery = new Parse.Query(Step);

        stepQuery.greaterThanOrEqualTo("startDate", lastSunday);
        stepQuery.lessThanOrEqualTo("endDate" , nextSunday);
        stepQuery.equalTo("User", user);


        return stepQuery.find( {

            success: function(results) {
            var sum = 0;
            console.log(results[0]);

            console.log(results[results.length-1]);
            for (var i = 0; i < results.length; i++){
            sum += results[i].get("quantity");
            }
            user.set("weeklySteps", sum);
            user.save();
            //response.success()
            },
              error: function() {
              //response.error("movie lookup failed");
            }
        });


    }).then(function() {
        console.log("DONE HERE");
    });



    return promise;

  })   .then(function() {
    //console.log("leaderBoardStatus complete console log");
    status.success("update complete");  
    response.success(); },function(error) {
    status.error("Uh oh, someting went wrong"); 
    response.error(); });

});

function getLastSunday(d) {
  var t = new Date(d);
  t.setDate(t.getDate() - t.getDay());
  t.setHours(0);
  t.setMinutes(0);
  t.setSeconds(0);
  t.setMilliseconds(0);
  return t;
}
function getNextSunday(d) {
  var t = getLastSunday(d);
  t.setDate(t.getDate() + 7);
  return t;
}
 
Parse.Cloud.job("notifications" , function(request, response) {
    Parse.Push.send({
  where: new Parse.Query(Parse.Installation),
  data: {
    alert: "Don't forget to push your movement data."
  }
}, {
  success: function() {
    // Push was successful
  },
  error: function(error) {
    // Handle error
  }
});
});

function handleRecord(record , user){
		var startDate = new Date(record['startDate'])
		var endDate = new Date(record['endDate'])
		var quantity = record['quantity']
		var type = record['sampleType'];

		if (type == "Step" ){
			var record = new Step();	
			quantity = parseInt(quantity)
		} else if (type == "Distance"){
			var record = new Distance();
			quantity = parseFloat(quantity)

		}else if (type == "Flight") {
			var record = new Flight();
			quantity = parseInt(quantity)
		}
		 if (typeof record !== 'undefined'){
		 	record.set("startDate", startDate);

		 	record.set("endDate", endDate);

		 	record.set("quantity", quantity);
		 	record.set("sampleType", type);
		 	record.set("User", user);
		 	record.save(null, {
            success:function (record) {
            },
            error:function (pointAward, error) {
                console.log("Could not save record " + error.message);
            }
        }
    );
		 }
		//console.log(type);
}
/*
var factory = function(){
    var time = 0, count = 0, difference = 0, queue = [];
    return function limit(func){
        if(func) queue.push(func);
        difference = 1000 - (performance.now() - time);
        if(difference <= 0) {
            time = performance.now();
            count = 0;
        }
        if(++count <= 10) (queue.shift())();
        else setTimeout(limit, difference);
    };
};
*/
var toBeSaved = Parse.Object.extend("toBeSaved");
Parse.Cloud.job("handleTempObjects", function(request,status) {
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query(toBeSaved);
    query.notEqualTo("outdated", true);
    query.notEqualTo("saved", true);
    console.log("here");
    var size = 800;
	//var limited = factory();
    query.each(function(tbs){
        //console.log(JSON.stringify(tbs.get("objectID")));
        var file = tbs.get("ObjectsToBeSaved");
        var user = tbs.get("User")
        var startRow = tbs.get("onRow")
        if (typeof startRow === 'undefined'){
        	startRow = 0
        }
        console.log(startRow)
        //console.log(JSON.stringify(file.url()));
         Parse.Cloud.httpRequest({url: file.url() }).then(function(response){
         	//var dataBuffer = JSON.stringify(response.buffer)
            var dataBuffer = response.buffer.toString('utf8') ;
           // console.log(dataBuffer)
            //console.log(dataBuffer);
            var recordarray = JSON.parse(dataBuffer);
            //console.log(recordarray[0])
            //console.log(recordarray[0]);
            console.log(recordarray.length)
            recordarray.slice(startRow,startRow + size).forEach(function(record){
            	//limited(function(){
            		handleRecord(record,user);
            	//});
     		});
     		tbs.set("onRow", startRow + size);
     		if (recordarray.length > startRow + size +size){
     		 	tbs.save();
     		}else{
     		 	tbs.set("saved", true);
     		 	tbs.save();
     		}
    });
});

});
