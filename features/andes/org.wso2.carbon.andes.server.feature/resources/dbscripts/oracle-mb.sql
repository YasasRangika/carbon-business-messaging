-- Copyright (c) 2015, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.

-- WSO2 Inc. licenses this file to you under the Apache License,
-- Version 2.0 (the "License"); you may not use this file except
-- in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.

-- WSO2 Message Broker Oracle Database schema --

-- Start of Message Store Tables --

/
CREATE TABLE MB_QUEUE_MAPPING (
    QUEUE_ID INT,
    QUEUE_NAME VARCHAR2(512) UNIQUE,
    CONSTRAINT PK_MB_QUEUE_MAPPING PRIMARY KEY (QUEUE_ID))
/
CREATE SEQUENCE MB_QUEUE_MAPPING_SEQUENCE START WITH 1 INCREMENT BY 1 NOCACHE
/
CREATE OR REPLACE TRIGGER MB_QUEUE_MAPPING_TRIGGER 
    BEFORE INSERT ON MB_QUEUE_MAPPING
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT MB_QUEUE_MAPPING_SEQUENCE.nextval INTO :NEW.QUEUE_ID FROM dual;
    END;
/
CREATE TABLE MB_METADATA (
    MESSAGE_ID NUMBER(19),
    QUEUE_ID INT,
    DLC_QUEUE_ID INT NOT NULL,
    MESSAGE_METADATA RAW(2000) NOT NULL,
    CONSTRAINT PK_MB_METADATA PRIMARY KEY (MESSAGE_ID),
    CONSTRAINT FK_MB_METADATA_QUEUE_MAPPING FOREIGN KEY (QUEUE_ID) REFERENCES MB_QUEUE_MAPPING (QUEUE_ID)
)
/
CREATE INDEX MB_METADATA_QUEUE_ID_INDEX ON MB_METADATA (QUEUE_ID);
/
CREATE TABLE MB_CONTENT (
    MESSAGE_ID NUMBER(19),
    CONTENT_OFFSET INT,
    MESSAGE_CONTENT BLOB NOT NULL,
    CONSTRAINT pk_messages PRIMARY KEY (MESSAGE_ID,CONTENT_OFFSET),
    CONSTRAINT FK_CONTENT FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA
    ON DELETE CASCADE
)
/
CREATE TABLE MB_EXPIRATION_DATA (
    MESSAGE_ID NUMBER(19) UNIQUE,
    EXPIRATION_TIME NUMBER(19),
    MESSAGE_DESTINATION VARCHAR2(512) NOT NULL,
    CONSTRAINT FK_EXPIRATION_DATA FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA (MESSAGE_ID)
)
/
CREATE TABLE MB_RETAINED_METADATA (
  TOPIC_ID INT,
  TOPIC_NAME VARCHAR2(512) NOT NULL,
  MESSAGE_ID INT NOT NULL,
  MESSAGE_METADATA RAW(2000) NOT NULL,
  CONSTRAINT PK_MB_RETAINED_METADATA PRIMARY KEY (TOPIC_ID)
)
/

-- End of Message Store Tables --

-- Start of Andes Context Store Tables --

/
CREATE TABLE MB_DURABLE_SUBSCRIPTION (
    SUBSCRIPTION_ID VARCHAR2(512) NOT NULL, 
    DESTINATION_IDENTIFIER VARCHAR2(512) NOT NULL,
    SUBSCRIPTION_DATA VARCHAR2(2048) NOT NULL
)
/
CREATE TABLE MB_NODE (
    NODE_ID VARCHAR2(512) NOT NULL,
    NODE_DATA VARCHAR2(2048) NOT NULL,
        CONSTRAINT PK_MB_NODE PRIMARY KEY (NODE_ID)
)
/
CREATE TABLE MB_EXCHANGE (
    EXCHANGE_NAME VARCHAR2(512) NOT NULL,
    EXCHANGE_DATA VARCHAR2(2048) NOT NULL,
    CONSTRAINT PK_MB_EXCHANGE PRIMARY KEY (EXCHANGE_NAME)
)
/
CREATE TABLE MB_QUEUE (
    QUEUE_NAME VARCHAR2(512) NOT NULL,
    QUEUE_DATA VARCHAR2(2048) NOT NULL,
    CONSTRAINT PK_MB_QUEUE PRIMARY KEY (QUEUE_NAME)
)
/
CREATE TABLE MB_BINDING (
    EXCHANGE_NAME VARCHAR2(512) NOT NULL,
    QUEUE_NAME VARCHAR2(512) NOT NULL,
    BINDING_DETAILS VARCHAR2(2048) NOT NULL,
    CONSTRAINT FK_MB_BINDING_EXCHANGE FOREIGN KEY (EXCHANGE_NAME) REFERENCES MB_EXCHANGE (EXCHANGE_NAME),
    CONSTRAINT FK_MB_BINDING_QUEUE FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE (QUEUE_NAME)
    ON DELETE CASCADE
)
/
CREATE TABLE MB_QUEUE_COUNTER (
    QUEUE_NAME VARCHAR2(512) NOT NULL,
    MESSAGE_COUNT NUMBER(19), 
    CONSTRAINT PK_QUEUE_COUNTER PRIMARY KEY (QUEUE_NAME) 
)
/
CREATE TABLE MB_SLOT (
    SLOT_ID NUMBER(19) NOT NULL,
    START_MESSAGE_ID NUMBER(19) NOT NULL,
    END_MESSAGE_ID NUMBER(19) NOT NULL,
    STORAGE_QUEUE_NAME VARCHAR2(512) NOT NULL,
    SLOT_STATE NUMBER(3) NOT NULL,
    ASSIGNED_NODE_ID VARCHAR2(512),
    ASSIGNED_QUEUE_NAME VARCHAR2(512),
    CONSTRAINT PK_MB_SLOT PRIMARY KEY (SLOT_ID)
)
/
CREATE SEQUENCE MB_SLOT_ID_SEQUENCE START WITH 1 INCREMENT BY 1  NOCACHE;
/
CREATE OR REPLACE TRIGGER MB_SLOT_ID_TRIGGER
    BEFORE INSERT ON MB_SLOT
    REFERENCING NEW AS NEW
    FOR EACH ROW
    BEGIN
        SELECT MB_SLOT_ID_SEQUENCE.nextval INTO :NEW.SLOT_ID FROM dual;
    END;
/
CREATE INDEX MB_SLOT_MESSAGE_ID_INDEX ON MB_SLOT (START_MESSAGE_ID, END_MESSAGE_ID);
/
CREATE INDEX MB_SLOT_QUEUE_INDEX ON MB_SLOT (STORAGE_QUEUE_NAME);
/
CREATE TABLE MB_SLOT_MESSAGE_ID (
    QUEUE_NAME VARCHAR2(512) NOT NULL,
    MESSAGE_ID NUMBER(19) NOT NULL,
    CONSTRAINT PK_MB_SLOT_MESSAGE_ID PRIMARY KEY (QUEUE_NAME,MESSAGE_ID)
)
/
CREATE TABLE MB_NODE_TO_LAST_PUBLISHED_ID (
    NODE_ID VARCHAR2(512) NOT NULL,
    MESSAGE_ID NUMBER(19) NOT NULL,
    CONSTRAINT PK_MB_LAST_PUBLISHED_ID PRIMARY KEY (NODE_ID)
)
/
CREATE TABLE MB_QUEUE_TO_LAST_ASSIGNED_ID (
    QUEUE_NAME VARCHAR2(512) NOT NULL,
    MESSAGE_ID NUMBER(19) NOT NULL,
    CONSTRAINT PK_MB_LAST_ASSIGNED_ID PRIMARY KEY (QUEUE_NAME)
)
/
CREATE TABLE MB_RETAINED_CONTENT (
  MESSAGE_ID INT,
  CONTENT_OFFSET INT,
  MESSAGE_CONTENT BLOB NOT NULL,
  CONSTRAINT PK_MB_RETAINED_CONTENT PRIMARY KEY (MESSAGE_ID,CONTENT_OFFSET)
)
/
CREATE TABLE MB_MSG_STORE_STATUS (
    NODE_ID VARCHAR2(512) NOT NULL,
    TIME_STAMP NUMBER(19), 
    CONSTRAINT PK_MSG_STORE_STATUS PRIMARY KEY (NODE_ID, TIME_STAMP) 
)
/
-- End of Andes Context Store Tables --
