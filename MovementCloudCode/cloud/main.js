// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
 
var Flight = Parse.Object.extend("Flight");
Parse.Cloud.beforeSave("Flight", function(request, response) {
  console.log("Running beforeSave");
  Parse.Cloud.useMasterKey() ;
   var query  = new Parse.Query(Flight);
   query.equalTo("startDate", request.object.get("startDate"));
   query.equalTo("endDate" , request.object.get("endDate"));
   query.equalTo("User", request.object.get("User"));
   query.first({
      success: function(object) {
        if (object) {
          response.error("Record already exists");
          console.log("Record already exists");
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
  console.log("Running beforeSave");
  Parse.Cloud.useMasterKey() ;
   var query  = new Parse.Query(Distance);
   query.equalTo("startDate", request.object.get("startDate"));
   query.equalTo("endDate" , request.object.get("endDate"));
   query.equalTo("User", request.object.get("User"));
   query.first({
      success: function(object) {
        if (object) {
          response.error("Record already exists");
          console.log("Record already exists");
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
  console.log("Running beforeSave");
  Parse.Cloud.useMasterKey() ;
   var query  = new Parse.Query(Step);
   query.equalTo("startDate", request.object.get("startDate"));
   query.equalTo("endDate" , request.object.get("endDate"));
   query.equalTo("User", request.object.get("User"));
   query.first({
      success: function(object) {
        if (object) {
          response.error("Record already exists");
          console.log("Record already exists"); 
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
 
Parse.Cloud.define("getWeeklyWinner", function(request, response) {
  var lastSunday = getLastSunday(new Date());
  var query = new Parse.Query(user);
  query.greaterThanOrEqualTo("syncedTo", lastSunday);
  query.limit(1);

  query.find( {

            success: function(results) {
            var sum = 0;
            var winner_index = Math.floor((Math.random() * results.length) + 1) ;
            for (var i = 0; i < results.length; i++){
                var u = results[i];
                if (i == winner_index) {
                  u.set("weeklywinner", true);
                }else{
                  u.set("weeklywinner", false);
              }
            } 
          },
              error: function() {
              response.error("weeklywinner failed");
            }
        });
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
  query.descending("weeklySteps");
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
 

 
 Parse.Cloud.job("jobUpdateStepLeaderboard", function(request,status) {
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
    alert: "Push your data and answer this week's question to be entered into the raffle!"
  }
}, {
  success: function() {
    response.success('scheduled order reminder notification');
  },
  error: function(error) {
    response.error('unable to schedule order reminder notification with error ' + error);
  }
});
});

function handleRecord(record , user){
		var startDate = new Date(record['startDate']);
		var endDate = new Date(record['endDate']);
		var quantity = record['quantity'];
		var type = record['sampleType'];

		if (type == "Step" ){
			var record = new Step();	
			quantity = parseInt(quantity);
		} else if (type == "Distance"){
			var record = new Distance();
			quantity = parseFloat(quantity);

		}else if (type == "Flight") {
			var record = new Flight();
			quantity = parseInt(quantity);
		}
		 if (typeof record !== 'undefined'){
		 	record.set("startDate", startDate);

		 	record.set("endDate", endDate);

		 	record.set("quantity", quantity);
		 	record.set("sampleType", type);
		 	record.set("User", user);
		 	record.save(null, {
            success:function (record) {
              console.log("save successful");
            },
            error:function (pointAward, error) {
                console.log("Could not save record " + error.message);
            }
        }
    );
     }
}


Parse.Cloud.job("removeDuplicateItems", function(request, status) {
  Parse.Cloud.useMasterKey();
  var _ = require("underscore");

  var hashTable = {};

  function hashKeyForTestItem(testItem) {
    var fields = ["User", "startDate", "endDate"];
    var hashKey = "";
    _.each(fields, function (field) {
        hashKey += testItem.get(field) + "/" ;
    });
    return hashKey;
  }
  var classNames = ["Step","Flight","Distance"];
  classNames.forEach(function(name) {
    var testItemsQuery = new Parse.Query(name);
    testItemsQuery.each(function (testItem) {
      var key = hashKeyForTestItem(testItem);

      if (key in hashTable) { // this item was seen before, so destroy this
          return testItem.destroy();
      } else { // it is not in the hashTable, so keep it
          hashTable[key] = 1;
      }

    }).then(function() {
      status.success("Migration completed successfully.");
    }, function(error) {
      status.error("Uh oh, something went wrong.");
    });
  });
  });


var toBeSaved = Parse.Object.extend("toBeSaved");
Parse.Cloud.job("handleTempObjects", function(request,status) {
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query(toBeSaved);
    query.notEqualTo("outdated", true);
    query.notEqualTo("saved", true);
    var size = 400;
    query.each(function(tbs){
        var file = tbs.get("ObjectsToBeSaved");
        var user = tbs.get("User");
        var startRow = tbs.get("onRow");
        if (typeof startRow === 'undefined'){
        	startRow = 0
        }
        Parse.Cloud.httpRequest({url: file.url() }).then(function(response){
            console.log("trying to parse");
            var dataBuffer = response.buffer.toString('utf8');
            var recordarray = eval(dataBuffer);
            recordarray.slice(startRow,startRow + size).forEach(function(record){
                console.log("record")
            		handleRecord(record,user);
       		},function(httpResponse) {
            console.error('Request failed with response code ' + httpResponse.status);
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
