/* ============================================================ 
    All of the aplication's custom javascript scripts goes here
   ============================================================

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

*/

// Prepare the Post status based on what button is pressed

$(document).ready(function() {

	$('#publish_btn').on('click', function() {
		$('#status').val('published');
	});

	$('#draft_btn').on('click', function() {
		$('#status').val('draft');
	});

	$('#trash_btn').on('click', function() {
		$('#status').val('trash');
	});
	
});

// Autocomplete the Tag/Category slug

$(document).ready(function() {

	$('input[name="name"').on('keyup', function(){
		var slug = $(this).val();
		
		// Replace all non-alphanumeric characters with a hypen
		slug = slug.replace(/([~!@#$%^&*()_+=`{}\[\]\|\\:;'<>,.\/? ])+/g, '-').replace(/^(-)+|(-)+$/g,'').toLowerCase();

		$('input[name="slug"]').val(slug);
	});

	$('input[name="title"').on('keyup', function(){
		var slug = $(this).val();
		
		// Replace all non-alphanumeric characters with a hypen
		slug = slug.replace(/([~!@#$%^&*()_+=`{}\[\]\|\\:;'<>,.\/? ])+/g, '-').replace(/^(-)+|(-)+$/g,'').toLowerCase();

		$('input[name="slug"]').val(slug);
	});

});

// Auto switch the bootstrap switcer on the Settings page.

$(document).ready(function(){

	var state = $('#social_media_state').val();
	state = parseInt(state);

	$('.make-switch').bootstrapSwitch('setState' , state);

});

// Activate the tag input

$(document).ready(function() {

	$.getJSON('/api/tags.json', function(tags_list) {
		$("#tags").select2({tags: tags_list});
	});
	
});


$(document).ready(function() {

	$.getJSON('/api/categories.json', function(categories_list) {
		$("#categories").select2({tags: categories_list});
	});
	
});


function getBlog(gb) {
	var location = gb;
	var pageURL = location.split('/');
	var blogName = pageURL[4];
	sessionStorage.selectedBlog = blogName;
}
$(document).ready(function () {
	var blogName = sessionStorage.selectedBlog;
	$("#comments_blogs_chosen > .chosen-single.chosen-default > span").html(blogName);
});

function getStatus(gs) {
	var location = gs;
	var pageURL = location.split('/');
	var statusName = pageURL[5];
	sessionStorage.selectedStatus = statusName;
}
$(document).ready(function(){
	var statusName = sessionStorage.selectedStatus;
	$(".chosen-container-single-nosearch > a.chosen-single > span").html(statusName);
});