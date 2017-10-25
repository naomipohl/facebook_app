# Homework 7: Facebook Lite
Due **November 1, 2017 at 11:59pm**.

## Before Starting
Be sure to review lectures <a href="https://www.seas.upenn.edu/~cis196/lectures/CIS196-2017f-lecture6.pdf" target="_blank">6</a> and <a href="https://www.seas.upenn.edu/~cis196/lectures/CIS196-2017f-lecture7.pdf" target="_blank">7</a>.

## Gems
Run the `bundle install` command to install all of the gems listed in the `Gemfile`.

## Task
In this homework, you will implement a subset of Facebook's features, namely the ability to sign up, log in, log out, post statuses, and add and remove friends.

## Migrations
You may use the Rails scaffold and model generators for this assignment. If you are asked to overwrite anything, always say no.

**User** The `users` table should have `name`, `email`, and `password_hash` (string) as columns. I recommend using the scaffold generator for `User`.<br>
**Status** The statuses table should have a `text` column and a reference to the `users` table. I recommend using the scaffold generator for `Status`.<br>
**Friendship** The friendship table will be join table containing two references to the `users` table and a `status` (string). To generate the two references, you should use `user:references` and `friend:references`. I recommend using the model generator for `Friendship`.

## Models

### Associations
**User** A user can have many statuses, which should be destroyed when the user is. A user can have many friendships, which should be destroyed when the user is. A user should have many friends through the friendships table.<br>
**Status** A status belongs to a user.<br>
**Friendship** A friendship belongs to a user. A friendship also belongs to a user with foreign key reference `friend_id`. To create this relationship, use: `belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'`.

### Validations
**User** Make sure that the `name` is present and has a minimum length of 2 characters. Make sure that an email is present and unique. Create a custom validation that makes sure the name is capitalized. If it's not, add an error to `name` with the message 'is not capitalized.'.<br>
**Status** Make sure that the `text` is present and is at least 5 characters long.<br>
**Friendship** Make sure that the `status` is present. Make sure that `friend` is unique in the scope of `user`.

### user.rb
In the `User` model, you will also have to `include BCrypt` and copy the `password` and `password=` methods from its [documentation](https://github.com/codahale/bcrypt-ruby). You will have to modify the `password` method to ensure that the code inside is only run if `password_hash` is not `nil`.

#### remove_friendship
A `user` should have an instance method named `remove_friendship` that takes in a `friend`. It should try to find the `Friendship` whose `user` column points to the current user and whose `friend` column points to the passed in `friend`. If this friendship is not `nil`, destroy it. It should try to find the `Friendship` whose `user` column points to the passed in `friend` and whose `friend` column points to the current user. If this friendship is not `nil`, destroy it.

#### send_friend_request
A `user` should have a method named `send_friend_request` that takes in a `friend`. If a `Friendship` already exists with `user` column pointing to the current user and `friend` column pointing to the passed in `friend`, then return. Otherwise, create a `Friendship` whose `user` column points to the current user, whose `friend` column points to the passed in `friend`, and with `status` 'pending'.

#### accept_friend_request
A `user` should have a method named `accept_friend_request` that takes in a `friend`. It should find or initialize (use the `find_or_initialize_by` method) a `Friendship` whose `user` column points to the current user and whose `friend` column points to the passed in `friend`. Update this friendship to have `status` accepted. Find or intialize a `Friendship` whose `user` column points to the passed in `friend` and whose `friend` column points to the current user.

#### Provided Methods
We are providing you with methods `#accepted_friends`, `#outgoing_friend_requests`, and `#incoming_friend_requests`. If your model generator accidentally overwrote this file, you should visit your GitHub repository and copy and paste these methods.

#### Run migrations
Be sure to run `rails db:migrate`.

## Controllers

### ApplicationController
You should define two helper methods called `logged_in?` and `current_user`.  `logged_in?` should tell you if a user is logged in, and `current_user` should return the instance of the logged in user.

Now that you've defined these methods, you should open `app/views/layouts/_nav.html.erb`. This file represents the nav bar for the app. If there is a user logged in, you should show the links to `current_user.name`, `Friend Requests`, and `Log out`. If the user is not logged in, you should show the links to `Sign up` and `Log in`.

### UsersController
This should already be generated by your scaffolding, but in case it wasn't, make sure you support the 7 RESTful routes.

#### show
Set the `@status` instance variable equal to a new `Status` instance.

#### create
After initializing a new user, be sure to call the user's `password` method (`@user.password = user_params[:password]`). Then attempt to `save` as normal. If the user saves properly, ensure that you log the user in (by setting `user_id` in the `session` hash).

#### update
If a user is updated successfully, be sure to log the user in.

#### destroy
After destroying the user, be sure to log the user out (by calling `reset_session`).

#### friend_requests
Define a `friend_requests` action. This should be a `get` request to `/friend_requests`. Inside of this action, you should redirect to the homepage unless there is a user logged in.

#### remove_friendship
Define a `remove_friendship` action. This should be a `delete` request to `/users/:id/remove_friendship`. Ensure that the `@user` variable is defined. Redirect to the homepage unless there is a user logged in. Otherwise, call `remove_friendship` on the current user with `@user` as an argument and redirect to the current user's show page.

#### send_friend_request
Define a `send_friend_request` action. This should be a `post` request to `/users/:id/send_friend_request`. Ensure that the `@user` variable is defined. Redrect to the homepage unless there is a user logged in. Otherwise, call `send_friend_request` on the current user with `@user` as an argument and redirect to `@user`'s show page.

#### accept_friend_request
Define an `accept_friend_request` action. This should be a `patch` request to `/users/:id/accept_friend_request`. Ensure that the `@user` variable is defined. Redirect to the homepage unless there is a user logged in. Otherwise, call `accept_friend_request` on the current user with `@user` as an argument and redirect to the current user's show page.

#### user_params
Ensure that `user_params` permits `:password` instead of `:password_hash`.

### SessionsController
I recommend creating this with the controller generator. You will need `new`, `create`, and `destroy` actions.

#### new
This should be a `get` request to `/login`. Set the `@user` instance variable equal to a new instance of `User`.

#### create
This should be a `post` request to `/login`. Try to find the user with the email from the `params` hash. If the user is not `nil` and the password in the `params` hash is equal to the user's password, log the user in and redirect to the homepage. Otherwise, redirect to the `/login` page.

#### destroy
This should be a `delete` request to `/logout`. Log the user out and redirect to the homepage.

### StatusesController
This should have been generated using the scaffold generator. Delete the `index` and `show` actions. Before every action, it should redirect to the homepage if the user is not logged in (this would be a good place for a `before_action`). Change all of the redirects to redirect to `@status.user`.

## Routes
You should have been defining the routes along the way, but here are all of the routes that you should have defined:
1. The homepage should point to the `welcome` controller's `index` action.
2. You should have the 7 RESTful routes for `users`.
3. Using [member routes](http://guides.rubyonrails.org/routing.html#adding-more-restful-actions) for `users`, handle a `delete` request to `remove_friendship`, a `post` request to `send_friend_request`, and a `patch` request to `accept_friend_request`.
4. You should have 5 RESTful routes for `statuses`. All except `index` and `show`.
5. Define a `get` request to `/login` that uses the `sessions` controller's `new` action.
6. Define a `post` request to `/login` that uses the `sessions` controller's `create` action.
7. Define a `delete` request to `/logout` that uses the `sessions` controller's `destroy` action.
8. Define a `get` request to `/friend_requests` that uses the `users` controller's `friend_requests` action.

## Submitting
To submit your assignment, `cd` into the Homework 7 directory. Run `git status` to see all of the changes that you've made. Run `git add .` to add all of the changed files and `git status` to confirm that they all appear in green. Run `git commit -m "Complete Homework 7"` to commit your changes locally (note that you can change the commit message to anything you want). Run `git push -u origin master` to push up the changes to your Homework 7 GitHub repository.

Visit Travis CI to see the result of your submission. You will be able to see all of your failed test cases and style offenses. You can submit as many times as you'd like, only your last submission will be graded.
