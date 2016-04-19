$(document).ready(function() {

//  Blog start overlay
if (document.cookie.indexOf("visited") >= 0) {
	//	if they have been visited this site before
	$(".blog-start").removeClass("show");
	$(".blog-start").addClass("hide");
	$("body").removeClass("active-overlay");

	if ($(".blog-start").hasClass("show")) {
		$(".user").addClass("hidden");
	} else {
		$(".user").removeClass("hidden");
	}

} else {
	expiry_date = new Date();
	expiry_date.setTime(expiry_date.getTime() + (12 * 4 * 7 * 24 * 60 * 60 * 1000));
	// Date()'s toUTCSting() method will format the date correctly for a cookie 
	// 12month * 4weeks * 7days ...so on
	document.cookie = "visited=yes; expires=" + expiry_date.toUTCString();

	$(".blog-start").addClass("show");
	$(".blog-start").removeClass("hide");
	$("body").addClass("active-overlay");
	
	$("#close_overlay").on('click', function () {
		$(".blog-start").slideToggle("slow");
		$(".blog-start").removeClass("show");
		$("body").removeClass("active-overlay");
		$(".user").removeClass("hidden");
	});
	$("#signin").on('click', function () {
		$(".blog-start").slideToggle("slow");
		$(".blog-start").removeClass("show");
		$("body").removeClass("active-overlay");
	});
	$("#register").on('click', function () {
		$(".blog-start").slideToggle("slow");
		$(".blog-start").removeClass("show");
		$("body").removeClass("active-overlay");
	});

	if ($(".blog-start").hasClass("show")) {
		$("body").addClass("active-overlay");
		$(".user").addClass("hidden");
	} else {
		$(".user").removeClass("hidden");
	}

}
//  END- Blog start overlay

//  cookie for "cookie bar"

function cookiesAccept(){
   days=60;
   myDate = new Date();
   myDate.setTime(myDate.getTime()+(days*24*60*60*1000));
   document.cookie = 'cookies=Accepted; expires=' + myDate.toGMTString();
}

var cookie = document.cookie.split(';')
    .map(function(x){ return x.trim().split('='); })
    .filter(function(x){ return x[0]==='cookies'; })
    .pop();

if (!(cookie && cookie[1]==='Accepted')) {
    $(".cookies").css("display", "block");
   // $(".header").css("transition","none");
   $(".header").css("top","31px");
}

$('.closeCookie').on('click', function(){
    cookiesAccept();
    return false;
});





    $(".input-group, .links-group:first").on('click',function(event){
        event.stopPropagation();
    });
//  END Header

    $("#header_onion_logo, #only-logo").on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        window.location = window.location.protocol + "//" + window.location.host + "/";
    }).on('mouseover', function (e) {
        $("#header_onion_logo").css('cursor','pointer');
    });


//  prettyprint
    $('pre').each(function(){ 
        var class_name = $(this).attr('class');
        if (class_name != undefined) {
            $(this).className = $(this).attr('class', class_name.replace(/brush:/,'prettyprint lang-').replace(/;$/,''));
        } else {
          $( "pre" ).removeClass().addClass( "prettyprint lang-" );

        }
    });

    $('code').each(function(){ 
      $( "code" ).removeClass().addClass( "prettyprint lang-" );
    });

    $(".reply_comment_div").each(function(){
        $(this).hide();
        $(this).find('form').prepend('<input type="hidden" value="' + this.id + '" name="in_reply_to" />');
        $(this).find('div .title').replaceWith( "<h5>Reply</h5>" );

        if ($(this).attr('id') == $(this).attr('div_set')) {
            // repopulate the submitted form
            $(this).find('input[id=name]').val($(this).attr('field_fullname'));
            $(this).find('input[id=email]').val($(this).attr('field_email'));
            $(this).find('input[id=website]').val($(this).attr('field_website'));
            $(this).find('textarea[name=comment]').val($(this).attr('field_comment'));
            $( this ).show(); //if this was submitted, show it again
        } else {
            //clear info from this kind of fields
            $(this).find('input[id=name]').val('');
            $(this).find('input[id=email]').val('');
            $(this).find('input[id=website]').val('');
            $(this).find('textarea[name=comment]').val('');
        }
    });

    $(".comment_reply").on('click', function( aaa ){
        var reply_comm = this.id + '_div';

        if ($("#" + reply_comm).is(":visible")) {
             $( "#" + reply_comm ).hide();
        } else {
            $( "#" + reply_comm ).show();
        }
    });

// register_done button

$("#start-blogging").on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        window.location = window.location.protocol + "//" + window.location.host + "/";
});


// ajax when toggle changes.
    $(function changeTheme(){

        $('#cmn-toggle-4').on('change',function() {
            var theme = $('#cmn-toggle-4').is(':checked');
            console.log("theme:",theme);
            $.ajax({
         //Assuming an endpoint here that responds to GETs with a response.
                url: "/theme" ,
                method: "POST",
                contentType: "application/x-www-form-urlencoded",
               data: { 
                  theme: theme
                }
            })
            .done(function (data) {
                var themeq = data.toString();
                var url = window.location.href;
                //var posts = JSON.parse();
                //console.log(themeq[]);

                $('.bubble').each(function() {

                    var src = $( this ).parent().find('img').attr('src');
                    console.log("src:",src);
                  
                    var userImg = $( this ).parent().find('img');
                    if (src !== undefined) { 
                        var defaultAvatar = (src.match(/\/blog\/img/g)||[]).length;

                        if (themeq === "light") {
                            $(".defaultAvatar").attr("src", "/blog/img/male-user-light.png");
                        } else if (themeq === "dark") {
                            $(".defaultAvatar").attr("src", "/blog/img/male-user.png");
                        }

                        if (themeq === "light" && defaultAvatar === 1) {
                            $("#theme").attr("href", "/blog/css/light.css");
                            $("#cmn-toggle-4").attr('checked', true);
                            userImg.attr('src', "/blog/img/male-user-light.png");
                        } 
                         else if (themeq === "light" && defaultAvatar === 0) {
                            $("#theme").attr("href", "/blog/css/light.css");
                            $("#cmn-toggle-4").attr('checked', true);
                        }
                         else if (themeq === "dark" && defaultAvatar === 1) {
                             $("#theme").attr("href", "/blog/css/dark.css"); 
                             $("#cmn-toggle-4").attr('checked', false);
                             userImg.attr('src', "/blog/img/male-user.png");
                        }
                         else if (themeq === "dark" && defaultAvatar === 0) {
                              $("#theme").attr("href", "/blog/css/dark.css");
                              $("#cmn-toggle-4").attr('checked', false);
                        }
                    }
             });
        });
        });
    });



    // Leave a comment for a blog post
    $("#reply_post_comment_button").on('click', function (e){
        var comment = $("#reply_post_comment_form #comment").val();
        var slug = $("#reply_post_comment_form #slug").val();
        var isEmpty = $.trim($("#reply_post_comment_form #comment").val());
        $("#reply_post_comment_form").trigger('reset');
        var themeinitial = $('#cmn-toggle-4').is(':checked');

        console.log(comment);
        console.log(slug);
      if (isEmpty == "") {
       // e.preventDefault();
       // e.stopPropagation();
        return false; 
      } else {
        $.ajax({
            method: "POST",
            url: "/comments",
            contentType: "application/x-www-form-urlencoded",
            data: {
              slug: slug,
              comment: comment
            }
        })
        .done(function (data) {
            var posts = JSON.parse(data);
            //for( var i= 0; i < posts.length; i++){
                var entryItem = $(".comment-list .comment").get(0),
                    newItem = $(entryItem).clone(),
                    avatarPath;

                    if (posts.status === 'approved') {
                    if (posts.user.avatar_path) {
                        avatarPath = posts.user.avatar_path;
                        } else if (themeinitial === false){ 
                            avatarPath = "/blog/img/male-user.png";
                        } else if (themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                        }

                newItem.find(".bubble img.user-image").attr("src", avatarPath);
                newItem.find(".comment-author a").html(posts.user.name);
                newItem.find(".comment-author a").attr("href", "/profile/author/" + posts.user.username);
                newItem.find(".content-comment .cmeta .hours").html(posts.comment_date_human);
                newItem.find(".content-comment p").html(posts.content);

               // newItem.insertBefore($(".comment"));
                  $($(".comment-list").get(0)).prepend(newItem);
                  newItem.removeClass('hidden');
            //}
                } else if (posts.status === 'pending') {
                    $(".display_msg").addClass("show");
                }
        });
      }
    });

    /* Strip image tags from post preview*/
    $('.post_preview_wrapper img').remove();

//    Truncate Post content
  $(".truncate").dotdotdot({
    ellipsis  : '... ',
  });


//    Register
  $("#confirmPasswordRegister").keyup(function() {
    if( $(this).val() !== $("#passwordRegister").val() ){
        $("#confirmPasswordRegister").addClass('error');
    } else {
        $("#confirmPasswordRegister").removeClass('error');
    }
  });

//Form Register validation

  function validationForm(event) {
      var email = $("#emailRegister").val();
      var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
      var username = $("#usernameRegister").val();
      var name = $("#displayNameRegister").val();
      var password = $("#passwordRegister").val();
      var confirmPassword = $("#confirmPasswordRegister").val();
      var errors = 0;
      var ascii = /^[\x21-\x7E]+/;
      var speciaCharacters = /[^\w\s\.@-]/g;

//      Email validation
      $('#register_form input').css('border-color' , '#CCC').removeClass('error');

      if (email.length < 1) { //      Email validation
        $('.change_error').text('Email field is necesary').css('color' , 'red');
        $('#emailRegister').css('border-color' , 'red');
        errors++;

      } else if (!(email).match(emailReg)) { //  Email Regex validation
        $('.change_error').text('Invalid Email').css('color' , 'red');
        $('#emailRegister').addClass('error');
        errors++;

      } else if (username.length < 3) { //      Username validation
        $('.change_error').text('Username field is necesary').css('color' , 'red');
        $('#usernameRegister').css('border-color' , 'red');
        errors++;

      } else if (!(username).match(ascii)) { //      Username ascii validation
        $('.change_error').text('Username characters must be in ascii table range').css('color' , 'red');
        $('.error_ascii').slideToggle( "slow" );
        $('#usernameRegister').css('border-color' , 'red');
          $("#usernameRegister").keyup(function() {
              $('.error_ascii').fadeOut( "slow" );
              $('#usernameRegister').css('border-color' , '0');
          })
        errors++;

      } else if ((username).match(speciaCharacters)) { //      Username special URL char validation
        $('.change_error').text('Username characters must be in ascii table range').css('color' , 'red');
        $('.error_char').slideToggle( "slow" );
        $('#usernameRegister').css('border-color' , 'red');
        $("#usernameRegister").keyup(function() {
              $('.error_char').fadeOut( "slow" );
              $('#usernameRegister').css('border-color' , '0');
          })
        errors++;

      }
      else if (name.length < 3) { //      Display name validation
        $('.change_error').text('Display name field is necesary').css('color' , 'red');
        $('#displayNameRegister').css('border-color' , 'red');
        errors++;

      }
      else if (password.length < 3) { //      Password validation
        $('.change_error').text('Password is necesary').css('color' , 'red');
        $('#passwordRegister').css('border-color' , 'red');
        errors++;

      }
      else if (confirmPassword !== password) { //      Confirm password validation
        $('.change_error').text("Confirm password doesn't mach with password").css('color' , 'red');
        $('#confirmPasswordRegister').css('border-color' , 'red');
        errors++;

      }

      if (errors === 0) {
        return true;
      }

      return false;
    }

  $("#register_form").on('submit', function() {
    if (validationForm()) // Calling validation function.
      {
        $("#register_form").submit(); // Form submission.
      } else {

      return false;
      }
    });


//my profile Email validation
  function isValidEmailAddress(emailAddress) {
    var error = 0;
    var email = $("#user_email").val();
    var pattern = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
       //return pattern.test(emailAddress);

     if (!(email).match(pattern)) { 
      $('#user_email').addClass('error');
       error++; 
     }
    if (error === 0) {
        return true;
      } 
      else {
        return false;
      } 
  };

  $("#changeSetings").on('submit', function() {
    if (isValidEmailAddress()) // Calling validation function.
      {
        $("#changeSetings").submit(); // Form submission.
      } else {
        $('#user_email').css('border-color' , 'red');
        return false;
      }
    });

// Image upload preview
  function readURL(input) {
    if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
      $('#image_upload_preview').attr('src', e.target.result).addClass('hidden');
        var imageStyle = $('#croppie-avatars .cr-image').get(0).style;
        imageStyle.removeProperty('transform-origin');
        imageStyle.removeProperty('transform');
        imageStyle.removeProperty('width');
        imageStyle.removeProperty('height');

        $('#croppie-avatars').croppie('bind', {
            url: e.target.result
        }, function() {
            var minZoom = +$('#croppie-avatars .cr-image')[0].style['transform']
                .split(")")
                .find(function(item) {
                    return item.indexOf('scale') >=0
                }).replace("scale(", '');

            minZoom = (minZoom < 1) ? minZoom : 1;

            $('#croppie-avatars .cr-slider').attr('min', minZoom).attr('max', 2);
        }).removeClass('hidden');
    }
      reader.readAsDataURL(input.files[0]);
    }
}

$("#file-upload").change(function () {
      readURL(this);
  });

//delete image
$(".modal-footer .delete-img").on('click', function(){
    var themeinitial = $('#cmn-toggle-4').is(':checked');
    $( "#file-upload" ).val("");
    if (themeinitial === false){
        $('#image_upload_preview').attr('src', '/blog/img/male-user.png');
    } else if (themeinitial === true) {
        $('#image_upload_preview').attr('src', '/blog/img/male-user-light.png');
    }

    $('[name=action_form]').val('delete');

    $('#image_upload_preview').removeClass('hidden');
    $('#croppie-avatars').addClass('hidden');
});


// Validation file input for img only
function stringEndsWithValidExtension(stringToCheck, acceptableExtensionsArray, required) {
    if (required == false && stringToCheck.length == 0) { return true; }
    for (var i = 0; i < acceptableExtensionsArray.length; i++) {
        if (stringToCheck.toLowerCase().endsWith(acceptableExtensionsArray[i].toLowerCase())) { return true; }
    }
    return false;
}


String.prototype.startsWith = function (str) { return (this.match("^" + str) == str) }

String.prototype.endsWith = function (str) { return (this.match(str + "$") == str) }


//submitting upload picture form

$(".save-img").click(function() {
    if (!stringEndsWithValidExtension($("[id*='file-upload']").val(), [".png", ".jpeg", ".jpg", ".bmp", ".gif"], false)) {
        $('.error_file').fadeIn().delay(3000).fadeOut(2000);  
        return false;
    }
    //croppie avatars
    var cropData= $('#croppie-avatars').croppie('get');
    var topLeftX = cropData.points[0];
    var topLeftY = cropData.points[1];
    var bottomRightX = cropData.points[2];
    var bottomRightY = cropData.points[3];

    $('#upload-img [name=top]').val(topLeftY);
    $('#upload-img [name=left]').val(topLeftX);
    $('#upload-img [name=width]').val(bottomRightX - topLeftX);
    $('#upload-img [name=height]').val(bottomRightY - topLeftY);
    $('#upload-img [name=zoom]').val(cropData.zoom);

    var widthCrop = $('#upload-img').find('input[name="width"]').val();
    var heighthCrop = $('#upload-img').find('input[name="height"]').val();
    var top = $('#upload-img').find('input[name="top"]').val();
    var left = $('#upload-img').find('input[name="left"]').val();

    console.log(widthCrop);
    console.log(heighthCrop);

    if (widthCrop !== '0' || heighthCrop !== '0' || top !== '0' || left !== '0') {
      $('[name=action_form]').val('crop');
    }

    $("#upload-img").submit();
});


//  My profile password confirmation 
    
  $("#confirmNewPassword").keyup(function() {
    if( $(this).val() !== $("#newPassword").val() ){
        $("#confirmNewPassword").addClass('error');
    } else {
        $("#confirmNewPassword").removeClass('error');
    }
  });


//  Sign up
    $('.sign-up').css('min-height',$(window).height()-80);
    $(window).resize(function(){
      $('.sign-up').css('min-height',$(window).height()-80);
    });

// Register
    $('.register').css('min-height',$(window).height()-80);
    $(window).resize(function(){
      $('.register').css('min-height',$(window).height()-80);
    });
//Listing page
	$('.blog').css('min-height', $(window).height()-$('footer').height()-45);
	$(window).resize(function(){
		$('.blog').css('min-height', $(window).height()-$('footer').height()-45);
	}); 
//Individual posts 
	$('.blog-post').css('min-height', $(window).height()-$('.blog-comment').height()-$('footer').height()-80);
	$(window).resize(function(){
		$('.blog-post').css('min-height', $(window).height()-$('.blog-comment').height()-$('footer').height()-80);
	}); 
//Pages page
  $('.pages').css('min-height', $(window).height()-$('footer').height()-45);
  $(window).resize(function(){
    $('.pages').css('min-height', $(window).height()-$('footer').height()-45);
  }); 

//Blog start overlay
  $('.blog-start').css('max-height', $(window).height()*0.99);
  $(window).resize(function(){
    $('.blog-start').css('max-height', $(window).height()*0.99);
  });
 
  $('.blog-start .row').css('max-height', $('.blog-start').height()-$('.header').height());
  $(window).resize(function(){
    $('.blog-start .row').css('max-height', $('.blog-start').height()-$('.header').height());
  });
 
  $('.blog-start-wrapper').css('height', $('.blog-start .row').height());
  $(window).resize(function(){
    $('.blog-start-wrapper').css('height', $('.blog-start .row').height());
  });


$(window).resize(function(){
  $(".truncate").dotdotdot({
    ellipsis  : '... ',
  });
});


});

//Back to top at refresh
$(window).on('beforeunload', function() {
    $(window).scrollTop(0);
});

//If No Posts
if ($(".no-posts").length > 0){
    $(".view-more").addClass("cut");

} else {
    $(".view-more").removeClass("cut");
}



    //Close search
    $("#close_search").on('click', function (e) {
           window.history.back();
    });

//Tabs label align and tabs min-height
$( ".tabs label" ).first().css( "margin-left", "10px" );

$('.search-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
$(window).resize(function(){
    $('.search-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".search-page .background-bar").outerHeight(true));
});

$('.author-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".author-page .background-bar").outerHeight(true) - $(".author-description").outerHeight(true));
$(window).resize(function(){
    $('.author-page .tab-content').css('min-height',$(window).height() - $("footer").outerHeight(true) - $(".author-page .background-bar").outerHeight(true) - $(".author-description").outerHeight(true));
});

//tab 1 user-posts
function getUserPosts(searchTerm, pageNumber, removeExistingPosts) {
        if (true === removeExistingPosts) {
            $('#tab-content1 .progressloader-holder').show();
        }
		var themeinitial = $('#cmn-toggle-4').is(':checked');

        $('.progressloader').show();
        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/search/posts/' + searchTerm + "/" + pageNumber,
            type: 'GET'
        })
            .done(function (data) {

                if (true === removeExistingPosts) {
                    $('#tab-content1 .entry:not(.hidden)').remove();
                }

                var posts = JSON.parse(data).posts;
                if (posts.length === 0) {
                    $(".view-more").addClass("cut");
                    if (pageNumber == 0) {
                        //$('.tabs .loading-posts').css('margin-bottom', '0');
                        $('.no-posts').show();
                    }
                } else {
                    if(posts.length < 10){
                        $(".view-more").addClass("cut");
                    } else{
                        $(".view-more").removeClass("cut");
                    }
                    $('.no-posts').hide();

                    //  textbox with that result.
                    for (var i = 0; i < posts.length; i++) {
                        var entryItem = $(".entry").get(0),
                            newItem = $(entryItem).clone(),
                            commentsText,
							avatarPath;

                        if (posts[i].nr_of_comments == 1) {
                            commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                        } else {
                            commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                        }


                        if (posts[i].user.avatar) {
                            avatarPath = posts[i].user.avatar;
                            } else if ( themeinitial === false) {
                           avatarPath = "/blog/img/male-user.png";
                            } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                            }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".user a").html(posts[i].user.name);
                        newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                        newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".post-heading h2 a").html(posts[i].title);
                        newItem.find(".comments-listings a").text(commentsText);
                        newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                        newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                        newItem.find(".date").text(posts[i].created_date_human);


                        newItem.insertBefore($(".loading-posts"));
                        newItem.removeClass('hidden');
                    }
                }
                $('#tab-content1 .progressloader').hide();
                $('#search-more-posts').attr("data-posts-number", pageNumber);

                  $(".truncate").dotdotdot({
                    ellipsis  : '... ',
                  });

                  if ($(".search-page .tabs .no-posts.no-posts-found1").css("display") == "block") {
                      $(".search-page .tabs .loading-posts").css("margin-bottom", "0");
                  }

            })
            .fail(function () {
                $('#tab-content1 .entry:not(.hidden)').remove();
                $('.no-posts').show();
            })
            .always(function () {
                //close search input
                $(".search-input").addClass("cut");
                $('#tab-content1 .progressloader-holder').hide();
            });
}
//tab 2: user-info;
    function getPeople(searchTerm) {
        var themeinitial = $('#cmn-toggle-4').is(':checked');
        $('#tab-content2 .progressloader-holder').show();
        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/search/user-info/' + searchTerm,
            type: 'GET'
        })
            .done(function (data) {
                $('#tab-content2 .user-info-entry:not(.hidden)').remove();

                var userInfo = JSON.parse(data).info;
                if (userInfo.length === 0){
                    $('.no-posts2').show();
                } else {
                    $('.no-posts2').hide();

                    //  textbox with that result.
                    for (var i = 0; i < userInfo.length; i++) {
                        var entryItem = $(".user-info-entry").get(0),
                            newItem = $(entryItem).clone(),
                            avatarPath;

                        if (userInfo[i].avatar_path) {
                            avatarPath = userInfo[i].avatar_path;
                            } else if ( themeinitial === false) {
                           avatarPath = "/blog/img/male-user.png";
                            } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                            }

                        newItem.find(".bubble img.user-image").attr("src", avatarPath);
                        newItem.find(".info-entry a").text(userInfo[i].name);
                        newItem.find(".info-entry a").attr("href", "/profile/author/" + userInfo[i].username);
                        newItem.find(".info-entry .date").text(userInfo[i].register_date);

                        newItem.find(".properties li.nr-blog span").text(userInfo[i].counts.blog);
                        newItem.find(".properties li.nr-entries span").text(userInfo[i].counts.post);
                        newItem.find(".properties li.nr-comments span").text(userInfo[i].counts.comment);


                        newItem.appendTo($(".user-info-listing"));
                        newItem.removeClass('hidden');
                    }
                }
            })
            .fail(function() {
                $('#tab-content2 .user-info-entry:not(.hidden)').remove();
                $('.no-posts2').show();
            })
            .always(function() {
                //close search input
                $(".search-input").addClass("cut");
                $('#tab-content2 .progressloader-holder').hide();
            });
    }
//tab3 : tags
    function getTags(searchTerm) {
        $('#tab-content3 .progressloader-holder').show();
        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/search/user-tags/' + searchTerm,
            type: 'GET'
        })
            .done(function (data) {
                $('#tab-content3 #tag-list li:not(.hidden)').remove();

                var tags = JSON.parse(data).tags;
                if (tags.length === 0){
                    $('.no-posts3').show();
                } else {
                    $('.no-posts3').hide();

                    //  textbox with that result.
                    for (var i = 0; i < tags.length; i++) {
                        var entryItem = $("#tag-list li").get(0),
                            newItem = $(entryItem).clone();

                        newItem.find("a.btn-tag").attr("href", "/posts/tag/" + tags[i].slug);
											if(tags[i].name.length < 30) {
                        newItem.find("a.btn-tag").html(tags[i].name);
											} else {
												newItem.find("a.btn-tag").html(tags[i].name.slice(0,30)+"...");
											}
                        newItem.appendTo($("#tag-list"));
                        newItem.removeClass('hidden');
                    }
                }
            })
            .fail(function() {
                $('#tab-content3 #tag-list li:not(.hidden)').remove();
                $('.no-posts3').show();
            })
            .always(function() {
                //close search input
                $(".search-input").addClass("cut");
                $('#tab-content3 .progressloader-holder').hide();
            });
    }

//search - for first tab : posts
    $('input[name=search_term]').on('keyup', function(e) {
        var code = (e.keyCode ? e.keyCode : e.which),
            searchTerm,
            activeTab,
            activeTabId; 

        if (code !== 13) {
            return false;
        }

        searchTerm = $('input[name=search_term]').val();
        $(".tabs-head h2 span").html(searchTerm);


        activeTab = $('input[name=tabs]:checked');
        activeTabId = activeTab.attr('id');

        activeTab.attr("data-search-term", searchTerm);

        if (activeTabId == 'tab1') {
            getUserPosts(searchTerm, 0, true);
        } else if (activeTabId == 'tab2') {
            getPeople(searchTerm);
        } else {
            getTags(searchTerm);
        }

    });


$('input[name=tabs]').on('change', function () {
    var searchTerm = $('input[name=search_term]').val(),
        activeTabId = $(this).attr('id'),
        prevSearchTerm = $(this).attr('data-search-term');

    if (prevSearchTerm !== searchTerm) {
        $(this).attr("data-search-term", searchTerm);

        if (activeTabId == 'tab1') {
            getUserPosts(searchTerm, 0, true);
        } else if (activeTabId == 'tab2') {
            getPeople(searchTerm);
        } else {
            getTags(searchTerm);
        }
    }
});

//more button - for posts search
$('#search-more-posts').click(function () {
    var button = $(this),
        searchTerm = $('input[name=search_term]').val(),
        pageNumber = +(button.attr("data-posts-number")) + 1;

    $('#tab-content1 .progressloader').show();
    getUserPosts(searchTerm, pageNumber, false);
});

//MORE BUTTON - for USER
var pageURL = window.location.pathname.split('/');
var newURL = pageURL[1] + "/" + pageURL[2];
var userName = "/" + pageURL[3];
var userURL = "posts/user";
var tagURL = "posts/tag";
var categoryURL = "posts/category";
if (newURL == userURL) {
    $("#latest_posts").addClass("hidden");
    //button MORE - for listing page - USER
    $('#more-posts').click(function() {
        var button = $(this),
            pageNumber =  +(button.attr("data-page-number")) + 1,
            pageURL = window.location.pathname.split('/'),
            userName = "/" + pageURL[3];

        $('.progressloader').show();

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/posts/user' + userName + '/page/' + pageNumber + '?format=JSON',
            type: 'GET'
        })
            .done(function(data) {
                var posts = JSON.parse(data).posts;
                var nrPage = JSON.parse(data).page;
                var maxPage = JSON.parse(data).total_pages;
                if ( nrPage >= maxPage ) {
                    $('#view_more').addClass('hidden');
                    $('#display_msg_posts').fadeIn().delay(1000).fadeOut(1500);
                }
                // Once the server responds with the result, update the
                //  textbox with that result.
                for( var i= 0; i < posts.length; i++){
                    var entryItem = $(".entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText;

                    if(posts[i].nr_of_comments ==  1){
                        commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                    } else{
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
                    newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);

                    if (posts[i].post_categories) {
                        var categoryItem = newItem.find('.category-item.hidden');
                        for (var j = 0; j < posts[i].post_categories.length; j++) {
                            var newCategoryItem = categoryItem.clone();

                            newCategoryItem.find('a').text(posts[i].post_categories[j].category.name);
                            newCategoryItem.find('a').attr('href', '/posts/category/' + posts[i].post_categories[j].category.slug);

                            newCategoryItem.removeClass('hidden');
                            newCategoryItem.insertAfter(newItem.find('.category-item').last());
                        }
                    }

                    newItem.insertBefore($(".loading-posts"));
                }

                $(".truncate").dotdotdot({
                    ellipsis  : '... ',
                });

                $('.progressloader').hide();
                button.attr("data-page-number", pageNumber);

              $(".truncate").dotdotdot({
                ellipsis  : '... ',
              });
            });
    });
        
} else if (newURL == tagURL) {
    $("#latest_posts").addClass("hidden");
    //button MORE - for listing page - TAGS
    $('#more-posts').click(function() {
        var button = $(this),
            pageNumber =  +(button.attr("data-page-number")) + 1,
            pageURL = window.location.pathname.split('/'),
            tagName = "/" + pageURL[3],
            themeinitial = $('#cmn-toggle-4').is(':checked');
        
        $('.progressloader').show();

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/posts/tag' + tagName + '/page/' + pageNumber + '?format=JSON',
            type: 'GET'
        })
            .done(function(data) {
                var posts = JSON.parse(data).posts;
                var nrPage = JSON.parse(data).page;
                var maxPage = JSON.parse(data).total_pages;
                if ( nrPage >= maxPage ) {
                    $('#view_more').addClass('hidden');
                    $('#display_msg_posts').fadeIn().delay(1000).fadeOut(1500);
                }
                // Once the server responds with the result, update the
                //  textbox with that result.
                for( var i= 0; i < posts.length; i++){
                    var entryItem = $(".entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText,
                        avatarPath;

                    if(posts[i].nr_of_comments ==  1){
                        commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                    } else{
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    if (posts[i].user.avatar && posts[i].user.avatar !== "/blog/img/male-user.png") {
                          avatarPath = posts[i].user.avatar;
                    } else if ( themeinitial === false) {
                          avatarPath = "/blog/img/male-user.png";
                    } else if ( themeinitial === true) {
                          avatarPath = "/blog/img/male-user-light.png";
                    }

                    newItem.find(".bubble img.user-image").attr("src", avatarPath);
                    newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
                    newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);

                    if (posts[i].post_categories) {
                        var categoryItem = newItem.find('.category-item.hidden');
                        for (var j = 0; j < posts[i].post_categories.length; j++) {
                            var newCategoryItem = categoryItem.clone();

                            newCategoryItem.find('a').text(posts[i].post_categories[j].category.name);
                            newCategoryItem.find('a').attr('href', '/posts/category/' + posts[i].post_categories[j].category.slug);

                            newCategoryItem.removeClass('hidden');
                            newCategoryItem.insertAfter(newItem.find('.category-item').last());
                        }
                    }

                    newItem.insertBefore($(".loading-posts"));
                }

                $(".truncate").dotdotdot({
                    ellipsis  : '... ',
                });

                $('.progressloader').hide();
                button.attr("data-page-number", pageNumber);

              $(".truncate").dotdotdot({
                ellipsis  : '... ',
              });

              $(".posts.listings .text-listing-entries .post_preview_wrapper *").not("p, pre, code, bold, strong, em, italic, strike, s, a, blockquote, ul, ol, li").each(function() {
                  var content = $(this).contents();
                  $(this).replaceWith(content);
              });
            });
    });
    
} else if (newURL == categoryURL) {
        $("#latest_posts").addClass("hidden");
    //button MORE - for listing page - CATEGORY
    $('#more-posts').click(function() {
        var button = $(this),
            pageNumber =  +(button.attr("data-page-number")) + 1,
            pageURL = window.location.pathname.split('/'),
            categoryName = "/" + pageURL[3],
            themeinitial = $('#cmn-toggle-4').is(':checked');
        
        $('.progressloader').show();

        $.ajax({
            // Assuming an endpoint here that responds to GETs with a response.
            url: '/posts/category' + categoryName + '/page/' + pageNumber + '?format=JSON',
            type: 'GET'
        })
            .done(function(data) {
                var posts = JSON.parse(data).posts;
                var nrPage = JSON.parse(data).page;
                var maxPage = JSON.parse(data).total_pages;
                if ( nrPage >= maxPage ) {
                    $('#view_more').addClass('hidden');
                    $('#display_msg_posts').fadeIn().delay(1000).fadeOut(1500);
                }
                // Once the server responds with the result, update the
                //  textbox with that result.
                for( var i= 0; i < posts.length; i++){
                    var entryItem = $(".entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText,
                        avatarPath;

                    if(posts[i].nr_of_comments ==  1){
                        commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                    } else{
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    if (posts[i].user.avatar && posts[i].user.avatar !== "/blog/img/male-user.png") {
                            avatarPath = posts[i].user.avatar;
                    } else if ( themeinitial === false) {
                           avatarPath = "/blog/img/male-user.png";
                    } else if ( themeinitial === true) {
                            avatarPath = "/blog/img/male-user-light.png";
                    }

                    newItem.find(".bubble img.user-image").attr("src", avatarPath);
                    newItem.find(".user a").attr("href", "/posts/user/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
                    newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);

                    if (posts[i].post_categories) {
                        var categoryItem = newItem.find('.category-item.hidden');
                        for (var j = 0; j < posts[i].post_categories.length; j++) {
                            var newCategoryItem = categoryItem.clone();

                            newCategoryItem.find('a').text(posts[i].post_categories[j].category.name);
                            newCategoryItem.find('a').attr('href', '/posts/category/' + posts[i].post_categories[j].category.slug);

                            newCategoryItem.removeClass('hidden');
                            newCategoryItem.insertAfter(newItem.find('.category-item').last());
                        }
                    }
                    newItem.insertBefore($(".loading-posts"));
                }

                $(".truncate").dotdotdot({
                    ellipsis  : '... ',
                });

                $('.progressloader').hide();
                button.attr("data-page-number", pageNumber);

              $(".truncate").dotdotdot({
                ellipsis  : '... ',
              });

              $(".posts.listings .text-listing-entries .post_preview_wrapper *").not("p, pre, code, bold, strong, em, italic, strike, s, a, blockquote, ul, ol, li").each(function() {
                  var content = $(this).contents();
                  $(this).replaceWith(content);
              });
            });
    });
} else {
    
//button MORE - for listing page
$('#more-posts').click(function() {
    var button = $(this),
        pageNumber =  +(button.attr("data-page-number")) + 1,
        themeinitial = $('#cmn-toggle-4').is(':checked');

    $('.progressloader').show();

    $.ajax({
        // Assuming an endpoint here that responds to GETs with a response.
        url: '/posts/page/' + pageNumber + '?format=JSON',
        type: 'GET'
    })
        .done(function(data) {
            var posts = JSON.parse(data).posts;
            // Once the server responds with the result, update the
            //  textbox with that result.
            for( var i= 0; i < posts.length; i++){
                var entryItem = $(".entry").get(0),
                    newItem = $(entryItem).clone(),
                    commentsText,
                    avatarPath;

                if(posts[i].nr_of_comments ==  1){
                    commentsText = "Comment (" + posts[i].nr_of_comments + ")";
                } else{
                    commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                }

                if (posts[i].user.avatar && posts[i].user.avatar !== "/blog/img/male-user.png") {
                      avatarPath = posts[i].user.avatar;
                } else if ( themeinitial === false) {
                      avatarPath = "/blog/img/male-user.png";
                } else if ( themeinitial === true) {
                      avatarPath = "/blog/img/male-user-light.png";
                }


                newItem.find(".bubble img.user-image").attr("src", avatarPath);
                newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                newItem.find(".user a").html(posts[i].user.name);
                newItem.find(".post-heading h2 a").html(posts[i].title);
                newItem.find(".comments-listings a").text(commentsText);
                newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug +"#comments");
                newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);

                    if (posts[i].post_categories) {
                        var categoryItem = newItem.find('.category-item.hidden');
                        for (var j = 0; j < posts[i].post_categories.length; j++) {
                            var newCategoryItem = categoryItem.clone();

                            newCategoryItem.find('a').text(posts[i].post_categories[j].category.name);
                            newCategoryItem.find('a').attr('href', '/posts/category/' + posts[i].post_categories[j].category.slug);

                            newCategoryItem.removeClass('hidden');
                            newCategoryItem.insertAfter(newItem.find('.category-item').last());
                        }
                    }

                newItem.insertBefore($(".loading-posts"));
            }

            $(".truncate").dotdotdot({
                ellipsis  : '... ',
            });

            $('.progressloader').hide();
            button.attr("data-page-number", pageNumber);
        });
    });
}
/* AUTHOR PROFILE PAGE RELATED JS */
if (newURL == 'profile/author') {
    if ($(".author-page input[name=author-tabs]:checked").attr('id') == "author-tab1") {
        $('#author-tab-content1').show();
    } else if ($(".author-page input[name=author-tabs]:checked").attr('id') == "author-tab2") {
        $('#author-tab-content2').show();
    } else {
        $('#author-tab-content3').show();
    }
}
$(".author-page input[name=author-tabs]").on("change", function(){
    var activeTab = $(this).attr('id');
    if (activeTab == "author-tab1") {
        $('#author-tab-content1').show();
        $('#author-tab-content2').hide();
        $('#author-tab-content3').hide();
    } else if (activeTab == "author-tab2") {
        $('#author-tab-content2').show();
        $('#author-tab-content1').hide();
        $('#author-tab-content3').hide();
    } else {
        $('#author-tab-content3').show();
        $('#author-tab-content1').hide();
        $('#author-tab-content2').hide();
    }

});

function getAuthorEntries (button) {
    var authorURL =
        $('.author-description .author-name>a').attr('href').split('/');
    var author = authorURL[3];
    var pageNumber = +(button.attr("data-page-number"));

    $('.loading-author-entries .progressloader').show();

    $.ajax({
        // Assuming an endpoint here that responds to GETs with a response.
        url: '/posts/user/' + author + '/page/' + pageNumber + '?format=JSON',
        type: 'GET'
    })
        .done(function (data) {
            var posts = JSON.parse(data).posts;

            if (posts.length === 0) {
                button.addClass('hidden');
                if (pageNumber == 0) {
                    $('.no-posts').removeClass('hidden');
                }
            } else {
                // TODO: daca se schimba in back-end si vin cate 10 odata, schimba aici in 10
                if (posts.length < 5) {
                    button.addClass('hidden');
                } else {
                    button.removeClass('hidden');
                }
                // Once the server responds with the result, update the
                //  textbox with that result.
                for (var i = 0; i < posts.length; i++) {
                    var entryItem = $(".author-entries .entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText;

                    if (posts[i].nr_of_comments == 1) {
                        commentsText =  "Comment (" + posts[i].nr_of_comments + ")";
                    } else {
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].title);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug)
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                    newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);


                    newItem.removeClass('hidden');
                    newItem.appendTo($(".author-entries"));
                }

                button.attr("data-page-number", pageNumber + 1);
            }
            $(".truncate").dotdotdot({
                ellipsis: '... ',
            });
        })
        .always(function () {
            $('.loading-author-entries .progressloader').hide();
        });
}
//Author profile
$('#more-author-entries').click(function (){
    getAuthorEntries($(this));
});

function getAuthorPages (button){
    var authorURL =
        $('.author-name>a').attr('href').split('/');
    var pageAuthor = authorURL[3];
    var pageNumber = +(button.attr("data-page-number"));

    //$('.loading-author-pages .progressloader').show();

    $.ajax({
        // Assuming an endpoint here that responds to GETs with a response.
        url: '/pages/user/' + pageAuthor + '/page/' + pageNumber + '?format=JSON',
        type: 'GET'
    })
        .done(function (data) {
                var pages = JSON.parse(data).pages;

                if (pages.length === 0) {
                    button.addClass('hidden');
                    if (pageNumber == 0) {
                        $('.no-pages').removeClass('hidden');
                    }
                } else {
                    // TODO: daca se schimba in back-end si vin cate 10 odata, schimba aici in 10
                    if (pages.length < 10) {
                        button.addClass('hidden');
                    } else {
                        button.removeClass('hidden');
                    }
                    // Once the server responds with the result, update the
                    //  textbox with that result.
                    for (var i = 0; i < pages.length; i++) {
                        var entryItem = $(".author-pages .entry").get(0),
                            newItem = $(entryItem).clone();

                        newItem.find(".info-entry .page").html(pages[i].title);
                        newItem.find(".page-preview-wrapper").html(pages[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                        newItem.find(".read-more").attr("href", '/pages/' + pages[i].slug);

                        newItem.removeClass('hidden');
                        newItem.appendTo($(".author-pages"));
                    }

										$(".text-listing-pages").find('*').removeAttr("style");
                    button.attr("data-page-number", pageNumber + 1);
                }
                $(".truncate").dotdotdot({
                    ellipsis: '... ',
                });
        });

}

//Author pages
$('#more-author-pages').click(function (){
    getAuthorPages($(this));
});

// Get  author entries when clicking on tab 2
$('input[name=author-tabs]').on('change', function () {
    var activeTabId = $(this).attr('id');

    if (activeTabId == 'author-tab2') {
        if ($('.author-entries .entry:not(.hidden)').length == 0) {
            $('#more-author-entries').addClass('hidden');
            getAuthorEntries($('#more-author-entries'));
        }
    } else if(activeTabId == 'author-tab3'){
        if ($('.author-pages .entry:not(.hidden)').length == 0) {
            $('#more-author-pages').addClass('hidden');
            getAuthorPages($('#more-author-pages'));
        }
				$(".truncate").dotdotdot({
					ellipsis: '... ',
				});
    }
});
// Get author entries when the page starts on tab 2
$(document).ready(function () {
    var activeTabId = $('input[name=author-tabs]:checked').attr('id');
    if (activeTabId == 'author-tab2') {
        $('#more-author-entries').addClass('hidden');
        getAuthorEntries($('#more-author-entries'));
    } else if (activeTabId == 'author-tab3') {
        $('#more-author-pages').addClass('hidden');
        getAuthorPages($('#more-author-pages'));
    }
});


$('#more-author-posts').click(function() {
    var authorURL =
        $('.author-description .author-name a').attr('href').split('/');
    var author = authorURL[3];

    $.ajax({
        // Assuming an endpoint here that responds to GETs with a response.
        url: '/profile/author/' + author + '?format=JSON', // add /page/number
        type: 'GET'
    })
        .done(function(data){
            var blogs = JSON.parse(data).blogs,
                blogsEntry = $('#author-tab-content1 .info-entry').get(0);

            // Once the server responds with the result, update the
            //  textbox with that result.

            for(var i= 0; i < blogs.length; i++){
                var newBlogsEntry = $(blogsEntry).clone();

                newBlogsEntry.find('.entry-name').text(blogs[i].name);
                newBlogsEntry.find('.information-blog').text(blogs[i].description);
                newBlogsEntry.find('.entries-count').text(blogs[i].count.post);
                newBlogsEntry.find('.entry-slug').attr('href', '/post/' + blogs[i].slug);

                newBlogsEntry.appendTo($('.author-entries-list'));
            }
        })
});




//More button for BLOGs individual page
$('#more-blog-posts').click(function() {
    var button = $(this),
        pageNumber =  +(button.attr("data-page-number")) + 1,
        url = window.location.pathname;

    $('.progressloader').show();

    $.ajax({
        // Assuming an endpoint here that responds to GETs with a response.
        url: url + '/page/' + pageNumber + '?format=JSON',
        type: 'GET'
    })
        .done(function(data) {
            var posts = JSON.parse(data).posts;

            if (posts.length === 0) {
                button.parents('.loading-posts').addClass('hidden');
                $('.no-more-posts').show();
            } else {
                // TODO: daca se schimba in back-end si vin cate 10 odata, schimba aici in 10
                if (posts.length < 10) {
                    button.parents('.loading-posts').addClass('hidden');
                    $('.no-more-posts').show();
                } else {
                    button.parents('.loading-posts').removeClass('hidden');
                }

                // Once the server responds with the result, update the
                //  textbox with that result.
                for (var i = 0; i < posts.length; i++) {
                    var entryItem = $(".entry").get(0),
                        newItem = $(entryItem).clone(),
                        commentsText;

                    if (posts[i].nr_of_comments == 1) {
                        commentsText =  "Comment (" + posts[i].nr_of_comments + ")";
                    } else {
                        commentsText = "Comments (" + posts[i].nr_of_comments + ")";
                    }

                    newItem.find(".user a").attr("href", "/profile/author/" + posts[i].user.username);
                    newItem.find(".post_preview_wrapper").html(posts[i].content.replace(/<img[^>]+>(<\/img>)?|<iframe.+?<\/iframe>|<video[^>]+>(<\/video>)?/g, ''));
                    newItem.find(".post-heading h2 a").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".user a").html(posts[i].user.name);
                    newItem.find(".post-heading h2 a").html(posts[i].title);
                    newItem.find(".comments-listings a").text(commentsText);
                    newItem.find(".comments-listings a").attr("href", "/post/" + posts[i].slug + "#comments");
                    newItem.find(".text-listing-entries a.read-more").attr("href", "/post/" + posts[i].slug);
                    newItem.find(".date").text(posts[i].created_date_human);

                    if (posts[i].post_categories) {
                        var categoryItem = newItem.find('.category-item.hidden');
                        for (var j = 0; j < posts[i].post_categories.length; j++) {
                            var newCategoryItem = categoryItem.clone();

                            newCategoryItem.find('a').text(posts[i].post_categories[j].category.name);
                            newCategoryItem.find('a').attr('href', '/posts/category/' + posts[i].post_categories[j].category.slug);

                            newCategoryItem.removeClass('hidden');
                            newCategoryItem.insertAfter(newItem.find('.category-item').last());
                        }
                    }

                    newItem.insertBefore($(".loading-posts"));
                }
            }

            $(".truncate").dotdotdot({
                ellipsis  : '... ',
            });

            $('.progressloader').hide();
            button.attr("data-page-number", pageNumber);

            $(".truncate").dotdotdot({
                ellipsis  : '... ',
            });
        });
    });

 if ($(".blog.blogs .no-posts").length > 0) {
    $(".blog.blogs .no-more-posts").hide();
 }

$("button.closeCookie").click(function(){
     $(".cookies").css("top","-31px").css("box-shadow","none");
     $(".header").css("transition","top 0.8s ease-in").css("top","0px");
});



