// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
 
var Step = Parse.Object.extend("Flight")
Parse.Cloud.beforeSave("Flight", function(request, response) {
  Parse.Cloud.useMasterKey() 
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
 
var Distance = Parse.Object.extend("Distance")
Parse.Cloud.beforeSave("Distance", function(request, response) {
  Parse.Cloud.useMasterKey() 
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
 
 var Step = Parse.Object.extend("Step")
Parse.Cloud.beforeSave("Step", function(request, response) {
  Parse.Cloud.useMasterKey() 
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
 
 
 
var  user = Parse.User.extend("User")
Parse.Cloud.beforeSave("User", function(request, response) {
  Parse.Cloud.useMasterKey() 
  Parse.Cloud.run('jobUpdateStepLeaderboard', {});   
  
});
 

Parse.Cloud.define("getLeaderboard" , function(request, response) {
   
  var query = new Parse.Query(user)
  query.descending("posts")
  query.limit(5)
  query.find({
    success : function(results){
        var list = [];
        for (i = 0; i < results.length; i++)
        {
          json = results[i].toJSON()
          for (var key in json){
            if(key!="username" && key!="posts"){
              delete json[key]
            }
          }
          list[i] = json
        }
        response.success(list)
      },
      error: function(error)
      {
        response.error("fail");
      }
     
  });
});
 
Parse.Cloud.define("getStepLeaderboard" , function(request, response) {
   
   var query = new Parse.Query(user)
  query.descending("posts")
  query.limit(5)
  query.find({
    success : function(results){
        var list = [];
        for (i = 0; i < results.length; i++)
        {
          json = results[i].toJSON()
          for (var key in json){
            if(key!="username" && key!="weeklySteps"){
              delete json[key]
            }
          }
          list[i] = json
        }
        response.success(list)
      },
      error: function(error)
      {
        response.error("fail");
      }
     
  });
 
});
 

 
 Parse.Cloud.job("jobUpdateStepLeaderboard", function(request,response) {
  Parse.Cloud.useMasterKey()
  var query = new Parse.Query(Parse.User);   // Query for all users   
  var lastSunday = getLastSunday(new Date())
  var nextSunday = getNextSunday(new Date())
  console.log(lastSunday)
  console.log(nextSunday)
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
            console.log(results[0])

            console.log(results[results.length-1])
            for (var i = 0; i < results.length; i++){
            sum += results[i].get("quantity")
            }
            user.set("weeklySteps", sum)
            user.save()
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
    response.success() },function(error) {
    status.error("Uh oh, someting went wrong"); 
    response.error()  });

});

function getLastSunday(d) {
  var t = new Date(d);
  t.setDate(t.getDate() - t.getDay());
  t.setHours(0)
  t.setMinutes(0)
  t.setSeconds(0)
  t.setMilliseconds(0)
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