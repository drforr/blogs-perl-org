$(document).ready(function(){
    var pageURL = window.location.pathname.split('/');
    userName = "/" + pageURL[5];

    $.ajax({
    // Assuming an endpoint here that responds to GETs with a response.
    url:  '/api/notification/comment/user/' + 'victor' + '/page/' + '0',
    type: 'GET'
  })
  .done(function(data) {
      // var oldStatus = JSON.parse(data)[0].old_status;
      // var nrPage = JSON.parse(data).page;
      // var maxPage = JSON.parse(data).total_pages;
      //  var JsonObject = JSON.parse(data)[i]
      // console.log(oldStatus);


// ======================
        var meh = JSON.parse(data);

        // invitation variables
        var invitation = document.getElementsByClassName("invitation-row");
        var invitationModal = $('<a href="#" data-toggle="modal" data-target="#invitation_modal" class="pull-right">View Invitation</a>');
        // var newInvitation = $(invitation).clone().appendTo(".card-design");

        // Content for New Invitations
        $(invitation).text(meh[0].comment.fullname + " added you as an " + meh[0].comment.user.role + " to the plm" );
        $(invitationModal).appendTo(invitation);

        // Response to invitations variables
        var ResponseInvitation = document.getElementsByClassName("response-row");
        // var ViewUsers =
// =============================


      // var title = document.getElementsByClassName("meh");
      // for(var i = 0; i < oldStatus.length; i++) {
      //     var h5 = document.createElement("h5");
      //     h5.innerHTML = oldStatus[i].title;
      //     title.appendChild(h5);
      //     // var p = document.createElement("p");
      //     // p.innerHTML = items[i].author;
      //     // news.appendChild(p);

      // }
    });

});






// });
