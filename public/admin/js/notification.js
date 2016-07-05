$(document).ready(function(){
    var pageURL = window.location.pathname.split('/');
    userName = "/" + pageURL[5];


    // Comments Section
    $.ajax({
    url:  '/api/notification/comment/user/' + 'victor' + '/page/' + '0',
    type: 'GET'
  })
  .done(function(data) {

        var data = JSON.parse(data);

        // Update nr of new Comments
        $('.commentsNr').text(data.total + ' New Comments');
    });



    // Invitations
    $.ajax({
    url:  '/api/notification/invitation/user/' + 'victor' + '/page/' + '0',
    type: 'GET'
  })
  .done(function(data) {
    var data = JSON.parse(data);

    // Update the Number of Invitations
    $('.invitationNr').text(data.total + ' New Invitation(s) to Join the Blog(s)');

    // invitation variables
    var invitation = document.getElementsByClassName("invitation-row");
    var invitationModal = $('<a href="#" data-toggle="modal" data-target="#invitation_modal" class="pull-right">View Invitation</a>');
    // var newInvitation = $(invitation).clone().appendTo(".card-design");


    // Content for New Invitations
    $(invitation).text(data.notifications[0].sender.username + " added you as an " +data.notifications[0].role + " to the " +  data.notifications[0].blog.name +' blog');

    // Modal Stuff
    $(invitationModal).appendTo(invitation);
    $('.invitation-blogname').text('I would like to invite you to join my blog ' + data.notifications[0].blog.name);
    $('.invitation-username').text(data.notifications[0].sender.username);
  });


  // Response Section
  $.ajax({
  url:  '/api/notification/response/user/' + 'victor' + '/page/' + '0',
  type: 'GET'
})

.done(function(data) {
    var response = JSON.parse(data);

    // Update the Number of Responses
    $('.responseNr').text(response.total + ' New Responses to Your Invitations');

    // response variables
    var responseRow = $('.response-row');
    var responseStatus;


    // Stringnify accepted/rejected + that freaking icon
    response.notifications[0].accepted === 0 ? responseStatus = "rejected" : responseStatus = "accepted";

    // Populating response row
    $(responseRow).text(response.notifications[0].receiver.username + ' ' + responseStatus + ' your invitation to join ' + response.notifications[0].blog.name);

    // Didn't combine with the above condition responseStatus needs to be defined, but icons need the row populated to prepend on
     (response.notifications[0].accepted === 0) ? (responseRow.prepend('<i class="fa fa-times-circle custom-fonts" aria-hidden="true"></i>').append('<a href="#" class="pull-right">View Users</a>')) : ($('.response-row').prepend('<i class="fa fa-plus-circle custom-fonts" aria-hidden="true"></i>').append('<a href="#" class="pull-right">View Users</a>'));
  });


});


// Response Section
$.ajax({
url:  '/api/notification/changed_role/user/' + 'victor' + '/page/' + '0',
type: 'GET'
})

.done(function(data) {
  var role = JSON.parse(data);

  // Update the Number of Responses
  $('.roleNr').text(role.total + ' Other Notifications');

      $('.role-row').text('Your role on the ' + role.notifications[0].blog.name + ' blog has been changed from ' + role.notifications[0].old_status + ' to ' + role.notifications[0].role);
});



 // More arrow/button

 $('.down-arrow').click(function() {
     var button = $(this),
         pageURL = window.location.pathname.split('/'),
         pageNumber =  +(button.attr("data-page-number")) + 1;
        //  userName = "/" + pageURL[3],
         debugger;
     $('.progressloader').show();

   });

// });
