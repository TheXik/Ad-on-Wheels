CREATE TABLE user_credentials
(
    id         BIGINT AUTO_INCREMENT NOT NULL,
    email      VARCHAR(255)          NOT NULL,
    password   VARCHAR(255)          NOT NULL,
    `role`     VARCHAR(255)          NOT NULL,
    profile_id BIGINT                NOT NULL,
    CONSTRAINT pk_user_credentials PRIMARY KEY (id)
);

ALTER TABLE user_credentials
    ADD CONSTRAINT uc_user_credentials_email UNIQUE (email);