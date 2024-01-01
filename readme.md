# info
- indexes could be created for faster data fetching but comes with a cost of more disk storage and slow write speed
  - indexes can be created by the below command
  ```SQL 
  CREATE INDEX <indexNAME> ON <tableNAME>(<tableFieldName>)
  ```

# Remember:
- username for user should be min 4 and max 15

# TODO:
- [ ] code coverage check

- [ ] client side hashing with salting [bard response](https://g.co/bard/share/556fcd2d893d) 
> password + salt = hash_password
> store hash_password and salt in the db

- [ ] enforce strong password validation on client
- [ ] bio should be updated from the profile edit page
- [ ] create a api documentation