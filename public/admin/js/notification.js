$(document).ready(function(){
    var pageURL = window.location.pathname.split('/');
    var SessionUsername = $('#sessionUsername').text();
    var invitation = $(".invitation-row")[0];
    var response = $(".response-row")[0];
    var role = $(".role-row")[0];
    var CommentPage = 1;
    var InvitationPage =  1;
    var ResponsePage =  1;
    var RolePage =  1;



    // Comments Function =====================
var  CommentsSection = function() {

    $.ajax({
    url:  '/api/notification/comment/user/' + SessionUsername + '/page/' + CommentPage,
    type: 'GET'
  })
    .done(function(data) {
      var CommentData = JSON.parse(data);
          // Update nr of new Comments
          $('.commentsNr').prepend( CommentData.total + ' New Comments');
      });
    }; // <- End of Comments Function


    // Invitation Function ===========================
var InvitationSection = function() {

  $.ajax({
    url:  '/api/notification/invitation/user/' + SessionUsername + '/page/' + InvitationPage++,
    type: 'GET'
  })
  .done(function(data) {
    var InvitationData = JSON.parse(data);
    var totalPages = InvitationData.total;
    var invitation_arrow = $(".invitation-arrow");
    var invitationModal = $('<a href="#" data-toggle="modal" data-target="#invitation_modal" class="pull-right">View Invitation</a>');


    // Update the Number of Invitations
    $('.invitationNr').html(' ' + InvitationData.total + ' New Invitation(s) to Join the Blog(s)');

    // Pagination and making the arrow dissapear when all elements have loaded
    for (var i = (InvitationPage == 2) ? 1 : 0; i < InvitationData.notifications.length; i++) {
      $(invitation).clone().insertBefore(invitation_arrow);
     ($(invitation).first().nextUntil(invitation).length - 1) === totalPages ? $('.invitation-arrow').hide()  : $('.invitation-arrow').show();
    }

    // Populating each invitation row
  $('.invitation-row').each(function(idx, invitation) {

    // Invitation Row Content
    $(invitation).prepend('<a href="profile/author/' + InvitationData.notifications[idx].sender.username +  '">' + InvitationData.notifications[idx].sender.username + '</a>' + " added you as an " +  InvitationData.notifications[idx].role  + " to the " +  '<a href="/blogs/user/' + InvitationData.notifications[idx].blog.blog_creator.username  +'/slug/' + InvitationData.notifications[idx].blog.slug + '">' + InvitationData.notifications[idx].blog.name + '</a>'+' blog');

    // Handling each Modal
    var modal = invitationModal.clone();
      $(modal).appendTo(invitation);
      $(modal).on('click', function() {
        $('.invitation-blogname').html('I would like to invite you to join my blog ' + '<a href="#">' + InvitationData.notifications[idx].blog.name + '</a>' + '.');
        $('.invitation-username').html('<a href="#">' + InvitationData.notifications[idx].sender.username + '</a>');
      });
      $(invitation).removeClass("invitation-row");
   });
  });
}; // <- end of Invitation Function


  // Response Function =========================
var ResponseSection = function() {

  $.ajax({
  url:  '/api/notification/response/user/' + SessionUsername + '/page/' + ResponsePage++,
  type: 'GET'
})

.done(function(data) {

      var responseData = JSON.parse(data);
      var totalPages = responseData.total;
      var response_arrow = $(".response-arrow");
      var responseRow = $('.response-row');
      var responseStatus;
      var responseIcon;

    //  // Update the Number of Responses
     $('.responseNr').html(totalPages + ' New Responses to Your Invitations');


    // Pagination and making the arrow dissapear when all elements have loaded
     for (var i = (ResponsePage == 2) ? 1 : 0; i < responseData.notifications.length; i++) {
       $(response).clone().insertBefore(response_arrow);
      ($(response).first().nextUntil(response).length) === totalPages ? $('.response-arrow').hide()  : $('.response-arrow').show();
     }

     $('.response-row').each(function(idx, response) {

       // Populating view user for each link
       var ViewUser = $('<a href="/profile/author/' + responseData.notifications[idx].receiver.username  + ' " class="pull-right">View User</a>');
       var viewUserRow = ViewUser.clone();

       // Stringnify accepted/rejected and response Icon
       (responseData.notifications[idx].accepted === 0) ? (responseStatus = "rejected", responseIcon = '<i class="fa fa-times-circle custom-fonts" aria-hidden="true"></i>') : (responseStatus = "accepted", responseIcon = '<i class="fa fa-plus-circle custom-fonts" aria-hidden="true"></i>');

      //  Populating the response row
       $(response).prepend( responseIcon + '<a href="/profile/author/' + responseData.notifications[idx].receiver.username  + '">' + responseData.notifications[idx].receiver.username + '</a>' +  ' ' + responseStatus + ' your invitation to join ' + '<a href="/blogs/user/' +  '<a href="/blogs/user/' + responseData.notifications[idx].blog.blog_creator.username  +'/slug/' + responseData.notifications[idx].blog.slug + '">' + responseData.notifications[idx].blog.name + '</a>');

      //  Appending view user
       $(viewUserRow).appendTo(response);
       $(response).removeClass("response-row");
     }); // <- end of each
  }); // < -end of done
};  // <- end of Response Function


  // Role Function ============================
var RoleSection = function() {

  // Role Section
    $.ajax({
    url:  '/api/notification/changed_role/user/' + SessionUsername + '/page/' + RolePage++,
    type: 'GET'
    })
    .done(function(data) {
      var roleData = JSON.parse(data);
      var totalPages = roleData.total;
      var role_arrow = $(".role-arrow");
      var responseRow = $('.role-row');


    // Update the Number of Roles
    $('.roleNr').html('<a href="#">' + roleData.total + '</a>' + ' Other Notifications');

    // Pagination and making the arrow dissapear when all elements have loaded
   for (var i = (RolePage == 2) ? 1 : 0; i < roleData.notifications.length; i++) {
     $(role).clone().insertBefore(role_arrow);
    ($(role).first().nextUntil(role).length) === totalPages ? $('.role-arrow').hide()  : $('.role-arrow').show();
    }


    $('.role-row').each(function(idx, role) {

     //  Populating the role row
     $(role).prepend('Your role on the ' + '<a href="/blogs/user/' +  roleData.notifications[idx].blog.blog_creator.username + '/slug/'  +  roleData.notifications[idx].blog.slug + '">' +  roleData.notifications[idx].blog.name + '</a>'  + ' blog has been changed from ' + roleData.notifications[idx].old_status + ' to ' + roleData.notifications[idx].role);

    $(role).removeClass("role-row");

    }); // <- end of each
  }); // <- end of done
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
    InvitationSection();
  });

$('.response-arrow').click(function() {
    ResponseSection();
  });
$('.role-arrow').click(function() {
    RoleSection();
  });


 // Styling hack for the header  and sidebar (both get sent and in other zones this structure is needed)
  if (window.location.pathname === '/notification') {
    $('#header_onion_logo').hide();
    $('.sidey').css('margin-top', '30px');
    $('#notification-parent').show();
  }


}); // <- end of Document ready
