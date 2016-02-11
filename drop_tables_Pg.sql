--
-- Drop all tables and types in reverse order of creation.
--

DROP TABLE settings;
DROP TABLE comment;

DROP TYPE comment_status;

DROP TABLE post_tag;
DROP TABLE tag;
DROP TABLE post_category;
DROP TABLE asset;
DROP TABLE post;

DROP TYPE post_status;
DROP TYPE post_format;

DROP TABLE category;
DROP TABLE blog_owners;
DROP TABLE blog;
DROP TABLE acl;
DROP TABLE ability;
DROP TABLE user_oauth;
DROP TABLE oauth;
DROP TABLE "user";
DROP TABLE theme;

DROP TYPE active_state;

DROP TABLE role;
