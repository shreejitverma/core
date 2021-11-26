@cli @external_storage @skipOnLDAP
Feature: using files external service with storage as webdav_owncloud

  As a user
  I want to be able to use webdav_owncloud as external storage
  So that I can extend my storage service

  Background:
    Given using server "REMOTE"
    And user "Alice" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "TestMnt"
    And using server "LOCAL"

  @issue-38165 @skipOnDbOracle
  Scenario: creating a webdav_owncloud external storage
    When the administrator creates an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And the administrator verifies the mount configuration for local storage "TestMountPoint" using the occ command
    Then the following mount configuration information should be listed:
      | status | code | message |
      | ok     | 0    |         |
    And as "admin" folder "TestMountPoint" should exist

  @skipOnEncryption @issue-encryption-181 @skipOnDbOracle @issue-38165
  Scenario: using webdav_owncloud as external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    When user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And using server "REMOTE"
    Then as "Alice" file "/TestMnt/test.txt" should exist
    And the content of file "/TestMnt/test.txt" for user "Alice" should be "Hello from Local!"

  Scenario: deleting a webdav_owncloud external storage
    Given using server "REMOTE"
    And user "Alice" has created folder "TestMnt1"
    And using server "LOCAL"
    And the administrator creates an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt1           |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint1    |
      | authentication_backend | password::password |
    When the administrator deletes external storage with mount point "TestMountPoint1"
    Then the command should have been successful
    When the administrator lists all local storage mount points using the occ command
    Then mount point "/TestMountPoint1" should not be listed as an external storage


    Scenario: adding an user to a webdav_owncloud external storage
      Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
        | host                   | %remote_server%    |
        | root                   | TestMnt            |
        | secure                 | false              |
        | user                   | %username%         |
        | password               | %password%         |
        | storage_backend        | owncloud           |
        | mount_point            | TestMountPoint     |
        | authentication_backend | password::password |
      And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
      And user "Brian" has been created with default attributes and without skeleton files
      When the administrator adds user "Brian" as the applicable user for local storage mount "TestMountPoint" using the occ command
      Then the command should have been successful
      # if the user's list is empty, resources in mount_point will be accessible to every users
      And the following users should be listed as applicable for local storage mount "TestMountPoint":
        | users  | Brian |
      And as "Brian" file "TestMountPoint/test.txt" should exist


    Scenario: removing an user from a webdav_owncloud external storage
      Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
        | host                   | %remote_server%    |
        | root                   | TestMnt            |
        | secure                 | false              |
        | user                   | %username%         |
        | password               | %password%         |
        | storage_backend        | owncloud           |
        | mount_point            | TestMountPoint     |
        | authentication_backend | password::password |
      And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
      And user "Brian" has been created with default attributes and without skeleton files
      And the administrator has added user "Brian" as the applicable user for local storage mount "TestMountPoint"
      And the administrator has added user "admin" as the applicable user for local storage mount "TestMountPoint"
      And the following users have been listed as applicable for local storage mount "TestMountPoint":
        | users  | Brian, admin |
      When the administrator removes user "Brian" from the applicable user for local storage mount "TestMountPoint" using the occ command
      Then the command should have been successful
      And the following users should be listed as applicable for local storage mount "TestMountPoint":
        | users  | admin |
      And as "Brian" file "TestMountPoint/test.txt" should not exist


  Scenario: adding a group to a webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And user "Brian" has been created with default attributes and without skeleton files
    And group "grp1" has been created
    And user "Brian" has been added to group "grp1"
    When the administrator adds group "grp1" as the applicable group for local storage mount "TestMountPoint" using the occ command
    Then the command should have been successful
    And the following groups should be listed as applicable for local storage mount "TestMountPoint":
      | groups  | grp1 |
    And as "Brian" file "TestMountPoint/test.txt" should exist


  Scenario: removing a group from a webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And user "Brian" has been created with default attributes and without skeleton files
    And group "grp1" has been created
    And user "Brian" has been added to group "grp1"
    And the administrator has added group "grp1" as the applicable group for local storage mount "TestMountPoint"
    And the administrator has added user "admin" as the applicable user for local storage mount "TestMountPoint"
    And the following groups have been listed as applicable for local storage mount "TestMountPoint":
      | groups  | grp1 |
    When the administrator removes group "grp1" from the applicable group for local storage mount "TestMountPoint" using the occ command
    Then the command should have been successful
    And the applicable groups list should be empty for local storage mount "TestMountPoint"
    And as "Brian" file "TestMountPoint/test.txt" should not exist


  Scenario: removing all users and groups from a webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And user "Brian" has been created with default attributes and without skeleton files
    And group "grp1" has been created
    And user "Brian" has been added to group "grp1"
    And the administrator has added group "grp1" as the applicable group for local storage mount "TestMountPoint"
    And the administrator has added user "admin" as the applicable user for local storage mount "TestMountPoint"
    And the administrator has added user "Brian" as the applicable user for local storage mount "TestMountPoint"
    And the following users have been listed as applicable for local storage mount "TestMountPoint":
      | users  | admin, Brian |
    And the following groups have been listed as applicable for local storage mount "TestMountPoint":
      | groups  | grp1 |
    When the administrator removes all from the applicable users and groups for local storage mount "TestMountPoint" using the occ command
    Then the command should have been successful
    And the applicable users list should be empty for local storage mount "TestMountPoint"
    And the applicable groups list should be empty for local storage mount "TestMountPoint"


  Scenario: exporting config from existing webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And user "Brian" has been created with default attributes and without skeleton files
    And group "grp1" has been created
    And user "Brian" has been added to group "grp1"
    And the administrator has added group "grp1" as the applicable group for local storage mount "TestMountPoint"
    And the administrator has added user "admin" as the applicable user for local storage mount "TestMountPoint"
    And the administrator has added user "Brian" as the applicable user for local storage mount "TestMountPoint"
    When the administrator exports the local storage mounts using the occ command
    Then the command should have been successful
    And the command should output configuration for local storage mount "TestMountPoint"


  Scenario: importing config to create a webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And the administrator has created a json file with exported config of local storage mount "TestMountPoint" to "mountConfig.json" in temporary storage
    And the administrator has deleted external storage with mount point "TestMountPoint"
    When the administrator imports the local storage mount from file "mountConfig.json" using the occ command
    Then the command should have been successful


  Scenario: setting read-only option for webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And user "Brian" has been created with default attributes and without skeleton files
    And the administrator has added user "Brian" as the applicable user for local storage mount "TestMountPoint"
    When the administrator sets the external storage "TestMountPoint" to read-only using the occ command
    Then the command should have been successful
    And user "Brian" should not be able to delete file "TestMountPoint/test.txt"
    And using server "REMOTE"
    And user "Alice" should be able to delete file "TestMnt/test.txt"


  Scenario: disabling and enabling share option for webdav_owncloud external storage
    Given the administrator has created an external mount point with the following configuration about user "Alice" using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | %username%         |
      | password               | %password%         |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And user "Brian" has been created with default attributes and without skeleton files
    And user "Carol" has been created with default attributes and without skeleton files
    And the administrator has added user "Brian" as the applicable user for local storage mount "TestMountPoint"
    When the administrator disables sharing for the external storage "TestMountPoint" using the occ command
    Then the command should have been successful
    And user "Brian" should not be able to share file "TestMountPoint/test.txt" with user "Carol" using the sharing API
    When the administrator enables sharing for the external storage "TestMountPoint" using the occ command
    Then user "Brian" should be able to share file "TestMountPoint/test.txt" with user "Carol" using the sharing API
    And as "Carol" file "test.txt" should exist

