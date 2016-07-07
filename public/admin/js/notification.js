$(document).ready(function(){
    var pageURL = window.location.pathname.split('/');
    // userName = "/" + pageURL[5];


    // Comments Function =====================
var  CommentsSection = function() {

    $.ajax({
    url:  '/api/notification/comment/user/' + 'victor' + '/page/' + '0',
    type: 'GET'
  })
    .done(function(data) {
          var data = JSON.parse(data);

          // Update nr of new Comments
          $('.commentsNr').prepend( data.total + ' New Comments');
      });
    }; // <- End of Comments Function


    // Invitation Function ===========================
var InvitationSection = function() {
    $.ajax({
    url:  '/api/notification/invitation/user/' + 'victor' + '/page/' + '0',
    type: 'GET'
  })
  .done(function(data) {
    var data = JSON.parse(data);
    var totalPages = data.total;
    var invitation = $(".invitation-row").get(0);





    // Update the Number of Invitations
    $('.invitationNr').prepend(' ' + data.total + ' New Invitation(s) to Join the Blog(s)');

    // invitation variables
    var invitationModal = $('<a href="#" data-toggle="modal" data-target="#invitation_modal" class="pull-right">View Invitation</a>');
    // var newInvitation = $(invitation).clone().appendTo(".card-design");


    // Content for New Invitations
    $(invitation).prepend('<a class="inviteUsername" href="profile/author/' + data.notifications[0].sender.username +  '">' + data.notifications[0].sender.username + '</a>' + " added you as an " +  data.notifications[0].role  + " to the " +  '<a href="/blogs/user/' + data.notifications[0].blog.blog_creator.username  +'/slug/' + data.notifications[0].blog.slug + '">' + data.notifications[0].blog.name + '</a>'+' blog');

    // Modal Stuff
    $(invitationModal).appendTo(invitation);
    $('.invitation-blogname').prepend('I would like to invite you to join my blog ' + '<a href="#">' + data.notifications[0].blog.name + '</a>' + '.');
    $('.invitation-username').prepend('<a href="#">' + data.notifications[0].sender.username + '</a>');

    for( var i= 1; i < data.notifications.length; i++){

          newRow = $(invitation).clone();

           newRow.find('.inviteUsername').attr('href', 'profile/author/' + data.notifications[i].sender.username);
           newRow.insertBefore('.invitation-arrow');
    } // <- end for
  });
}; // <- end of Invitation Function


  // Response Function =========================
var ResponseSection = function() {
  $.ajax({
  url:  '/api/notification/response/user/' + 'victor' + '/page/' + '0',
  type: 'GET'
})

.done(function(data) {
    var response = JSON.parse(data);

    // Update the Number of Responses
    $('.responseNr').prepend(response.total + ' New Responses to Your Invitations');

    // response variables
    var responseRow = $('.response-row');
    var responseStatus;


    // Stringnify accepted/rejected + that freaking icon
    response.notifications[0].accepted === 0 ? responseStatus = "rejected" : responseStatus = "accepted";

    // Populating response row
    $(responseRow).prepend('<a href="/profile/author/' + response.notifications[0].receiver.username + '">' + response.notifications[0].receiver.username + '</a>' + ' ' + responseStatus + ' your invitation to join ' + '<a href="/blogs/user/' + response.notifications[0].blog.blog_creator.username  +'/slug/' + response.notifications[0].blog.slug + '">' + response.notifications[0].blog.name + '</a>');


    // Didn't combine with the above condition responseStatus needs to be defined, but icons need the row populated to prepend on
     (response.notifications[0].accepted === 0) ? (responseRow.prepend('<i class="fa fa-times-circle custom-fonts" aria-hidden="true"></i>').append('<a href="#" class="pull-right">View Users</a>')) : ($('.response-row').prepend('<i class="fa fa-plus-circle custom-fonts" aria-hidden="true"></i>').append('<a href="#" class="pull-right">View Users</a>'));
  });
};  // <- end of Response Function


  // Role Function ============================
var RoleSection = function() {

  // Role Section
    $.ajax({
    url:  '/api/notification/changed_role/user/' + 'victor' + '/page/' + '0',
    type: 'GET'
    })
    .done(function(data) {
    var role = JSON.parse(data);

    // Update the Number of Responses
    $('.roleNr').prepend('<a href="#">' + role.total + '</a>' + ' Other Notifications');
    $('.role-row').prepend('Your role on the ' + '<a href="/blogs/user/' + role.notifications[0].blog.blog_creator.username + '/slug/' +  role.notifications[0].blog.slug + '">' + role.notifications[0].blog.name + '</a>' + ' blog has been changed from ' + role.notifications[0].old_status + ' to ' + role.notifications[0].role);
    });

}; // <- end of Role Function

  // Init comments
  CommentsSection();
  // Init Invitation Section
  InvitationSection();
  // Init Response Section
  ResponseSection();
  // Init Role Section
  RoleSection();

// More arrow/button

$('.invitation-arrow').click(function() {
    var button = $(this),
        pageURL = window.location.pathname.split('/'),
        pageNumber =  +(button.attr("moreInvitations")) + 1;
        debugger;

    $('.progressloader').show();
    InvitationSection();
  });

}); // <- end of Document ready
