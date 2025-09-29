var Login = {
	fnLogin : function() {
		$("#form").attr("action","/front/auth/loginProc");
		$("#form").submit();
	} 
}

function onSignIn(googleUser) {
    var profile = googleUser.getBasicProfile();
    console.log('ID: ' + profile.getId()); // Do not send to your backend! Use an ID token instead.
    console.log('Name: ' + profile.getName());
    console.log('Image URL: ' + profile.getImageUrl());
    console.log('Email: ' + profile.getEmail()); // This is null if the 'email' scope is not present.
    $("#googleId").val(profile.getId());
    $("#googleName").val(profile.getName());
    $("#googleEmail").val(profile.getEmail());
	$("#form").attr("action","/front/auth/googleLogin");
	$("#form").submit();
}
function onLoadGoogleCallback(){
	  gapi.load('auth2', function() {
	    auth2 = gapi.auth2.init({
	      client_id: '442434028472-bpigre700o77ehd0p9g4g8qhf4bobfjs.apps.googleusercontent.com',
	      cookiepolicy: 'single_host_origin',
	      scope: 'profile'
	    });

	  auth2.attachClickHandler(element, {},
	    function(googleUser) {
		  
		    var profile = googleUser.getBasicProfile();
		    console.log('ID: ' + profile.getId()); // Do not send to your backend! Use an ID token instead.
		    console.log('Name: ' + profile.getName());
		    console.log('Image URL: ' + profile.getImageUrl());
		    console.log('Email: ' + profile.getEmail()); // This is null if the 'email' scope is not present.
		    $("#googleId").val(profile.getId());
		    $("#googleName").val(profile.getName());
		    $("#googleEmail").val(profile.getEmail());
		  
			$("#form").attr("action","/front/auth/googleLogin");
			$("#form").submit();
		     
	        console.log('Signed in: ' + googleUser.getBasicProfile().getName());
	      }, function(error) {
	        console.log('Sign-in error', error);
	      }
	    );
	  });

	  element = document.getElementById('googleSignIn');
	}