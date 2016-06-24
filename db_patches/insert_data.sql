-- When a *web* user wants to perform an action, we should check whether
-- their user class has that particular ability.
--
-- This has nothing to do with whether the application is allowed to write
-- to a given table. For instance, while we have 'create tag', there is no
-- equivalent 'create post_tag' entry. If a user is allowed to change
-- a tag, then changing the post_tag reference is just one of the tasks that
-- should be done.
--
INSERT INTO ability
       VALUES -- Users should not be allowed to add their own role types.
              -- While the ability to do this coudd come in handy, it's too
              -- fraught with danger, especially .. say, accidentally removing
              -- the 'superadmin' user type.
              --
              -- And besides, the constraints in place shouldn't allow that
              -- to happen.
              -- 
              -- ('create role'), ('view role'),
              -- ('update role'), ('delete role'),

             -- Adding a theme to what's essentially a binary selection in
             -- the application means more changes than just adding a row.
             --
             -- ('create theme'), ('view theme'),
             -- ('update theme'), ('delete theme'),

             ('create users'), ('view users'),
             ('update users'), ('delete users'),

             -- ('create oauth'), ('view oauth'),
             -- ('update oauth'), ('delete oauth'),

             ('create user_oauth'), ('view user_oauth'),
             ('update user_oauth'), ('delete user_oauth'),

             -- It might be useful to let admins and superadmins see what
             -- permissions are available, but that's a long-term feature.
             --
             -- ('create ability'), ('view ability'),
             -- ('update ability'), ('delete ability'),
             --
             -- ('create acl'), ('view acl'),
             -- ('update acl'), ('delete acl'),

             ('create blog'), ('view blog'),
             ('update blog'), ('delete blog'),

             ('create blog_owners'), ('view blog_owners'),
             ('update blog_owners'), ('delete blog_owners'),

             ('create category'), ('view category'),
             ('update category'), ('delete category'),

             -- If a user updates a category, the application is responsible
             -- for updating the rest of the database, not the user.
             --
             -- ('create blog_categories'), ('view blog_categories'),
             -- ('update blog_categories'), ('delete blog_categories'),

             -- Adding a post format is more complex than updating a table,
             -- and is something that the application maintainer has to do.
             -- Users shouldn't be manipulating this table at all.
             --
             -- ('create post_format'), ('view post_format'),
             -- ('update post_format'), ('delete post_format'),

             ('create post'), ('view post'),
             ('update post'), ('delete post'),

             ('create page'), ('view page'),
             ('update page'), ('delete page'),

             -- Not sure where this is getting used, it may be removed.
             --
             ('create asset'), ('view asset'),
             ('update asset'), ('delete asset'),

             -- If a user changes a category, the application is responsible
             -- for updating the rest of the database, not the user.
             --
             -- ('create post_category'), ('view post_category'),
             -- ('update post_category'), ('delete post_category'),
             --
             -- ('create page_category'), ('view page_category'),
             -- ('update page_category'), ('delete page_category'),

             ('create tag'), ('view tag'),
             ('update tag'), ('delete tag'),

             -- If a user changes a tag, the application is responsible
             -- for updating the rest of the database, not the user.
             --
             -- ('create post_tag'), ('view post_tag'),
             -- ('update post_tag'), ('delete post_tag'),
             --
             -- ('create page_tag'), ('view page_tag'),
             -- ('update page_tag'), ('delete page_tag'),

             ('create comment'), ('view comment'),
             ('update comment'), ('delete comment'),

             -- Adding a notification type is more complex than updating this
             -- table, and is something that the application maintainer has to
             -- do.
             -- ('create notification_type'), ('view notification_type'),
             -- ('update notification_type'), ('delete notification_type'),

             -- Notifications are created by the application, not by the
             -- individual user. While they can mark a notification as being
             -- read, it's the application's responsibility to update the
             -- actual data.
             --
             -- ('create notification'), ('view notification'),
             -- ('update notification'), ('delete notification'),

             ('create settings'), ('view settings'),
             ('update settings'), ('delete settings'),
;


-- Users with the 'superadmin' role have the ability to do anything on the
-- site.
--
-- Admins have the ability to administrate their own blog(s), edit posts,
-- clean up spam comments and such.
--
-- Authors have the ability to edit their own blogs, posts and comments.
--
-- Visitors can view contents, but not edit anything
--
INSERT INTO role VALUES('superadmin'),
                       ('admin'),
                       ('author'),
                       ('visitor');


-- The ACL table details exactly the rights each class of user has.
-- We could make this hierarchical, but there's really no need to make this
-- that complicated.
--
INSERT INTO acl VALUES
             -- Superadmins should have the power to do everything.
             --
             ('superadmin','create users'), ('superadmin','view users'),
             ('superadmin','update users'), ('superadmin','delete users'),

             ('superadmin','create oauth'), ('superadmin','view oauth'),
             ('superadmin','update oauth'), ('superadmin','delete oauth'),

             ('superadmin','create user_oauth'), ('superadmin','view user_oauth'),
             ('superadmin','update user_oauth'), ('superadmin','delete user_oauth'),

             ('superadmin','create blog'), ('superadmin','view blog'),
             ('superadmin','update blog'), ('superadmin','delete blog'),

             ('superadmin','create blog_owners'), ('superadmin','view blog_owners'),
             ('superadmin','update blog_owners'), ('superadmin','delete blog_owners'),

             ('superadmin','create category'), ('superadmin','view category'),
             ('superadmin','update category'), ('superadmin','delete category'),

             ('superadmin','create post'), ('superadmin','view post'),
             ('superadmin','update post'), ('superadmin','delete post'),

             ('superadmin','create page'), ('superadmin','view page'),
             ('superadmin','update page'), ('superadmin','delete page'),

             -- Not sure where this is getting used, it may be removed.
             --
             ('superadmin','create asset'), ('superadmin','view asset'),
             ('superadmin','update asset'), ('superadmin','delete asset'),

             ('superadmin','create tag'), ('superadmin','view tag'),
             ('superadmin','update tag'), ('superadmin','delete tag'),

             ('superadmin','create comment'), ('superadmin','view comment'),
             ('superadmin','update comment'), ('superadmin','delete comment'),

             ('superadmin','create settings'), ('superadmin','view settings'),
             ('superadmin','update settings'), ('superadmin','delete settings'),

             -- Admins have the rights to do almost everything on the site.
             --
             ('admin','create blog'), ('admin','view blog'),
             ('admin','update blog'), ('admin','delete blog'),

             ('admin','create blog_owners'), ('admin','view blog_owners'),
             ('admin','update blog_owners'), ('admin','delete blog_owners'),

             ('admin','create category'), ('admin','view category'),
             ('admin','update category'), ('admin','delete category'),

             ('admin','create post'), ('admin','view post'),
             ('admin','update post'), ('admin','delete post'),

             ('admin','create page'), ('admin','view page'),
             ('admin','update page'), ('admin','delete page'),

             -- Not sure where this is getting used, it may be removed.
             --
             ('admin','create asset'), ('admin','view asset'),
             ('admin','update asset'), ('admin','delete asset'),

             ('admin','create tag'), ('admin','view tag'),
             ('admin','update tag'), ('admin','delete tag'),

             ('admin','create comment'), ('admin','view comment'),
             ('admin','update comment'), ('admin','delete comment'),

             -- Authors also have the rights to do almost everything on the
             -- site.
             --
             ('author','create blog'), ('author','view blog'),
             ('author','update blog'), ('author','delete blog'),

             -- Except add or remove authors on the blog, only admins are
             -- allowed.
             --
             ('author','view blog_owners'),

             ('author','create category'), ('author','view category'),
             ('author','update category'), ('author','delete category'),

             ('author','create post'), ('author','view post'),
             ('author','update post'), ('author','delete post'),

             ('author','create page'), ('author','view page'),
             ('author','update page'), ('author','delete page'),

             -- Not sure where this is getting used, it may be removed.
             --
             ('author','create asset'), ('author','view asset'),
             ('author','update asset'), ('author','delete asset'),

             ('author','create tag'), ('author','view tag'),
             ('author','update tag'), ('author','delete tag'),

             ('author','create comment'), ('author','view comment'),
             ('author','update comment'), ('author','delete comment'),

             -- Visitors have the rights to view content, but not edit it.
             --
             ('visitor','view blog'),

             ('visitor','view category'),

             ('visitor','view post'),

             ('visitor','view page'),

             -- Not sure where this is getting used, it may be removed.
             --
             ('visitor','view asset'),

             ('visitor','view tag'),

             ('visitor','view comment')
;


INSERT INTO notification_type VALUES('comment'),
                                    ('invitation'),
                                    ('response'),
                                    ('changed role')
;


INSERT INTO post_format VALUES('HTML'),
                              ('Markdown'),
                              ('Markdown_With_Smartypants'),
                              ('RichText'),
                              ('Textile2')
;


INSERT INTO theme VALUES('light'),
                        ('dark')
;


INSERT INTO oauth VALUES('LinkedIn'),
                        ('Facebook'),
                        ('GitHub'),
                        ('Twitter'),
                        ('Google')
;

-- The administrator user should be created using the scripts/mkpasswd tool,
-- this way the default configuration doesn't leave the application open to
-- exploits because of a plaintext user/password.
--
-- INSERT INTO users VALUES (1,'Admin','admin','XXX','2015-02-18 15:27:54','admin@admin.com',NULL,NULL,'admin',NULL,'active');
	
-- INSERT INTO category VALUES (1,'Uncategorized','uncategorized',1);


INSERT INTO settings VALUES ('Europe/Bucharest',1,'','/','BlogsPerlOrg',1,0);
