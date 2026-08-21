# Project Description

This is a Pigeon Race Management App

# Tech Stacks

- Flutter

Pointers when generating code:

# State Management:

- Use request_provider for API state management
  1

# UI Generation

- When adding inputs use the data_input.dart and just change the type, data_input automatically handles the data and is used with the request_provider when submitting data
- When creating modal with form or inputs use data_modal.dart
- Use DataListView when creating ListView
- Use AppScaffold as wrapper for all pages
- Success or Error message as much as possible should be returned by the endpoint

# data-input properties:

    required this.requestKey,
    required this.requestKey,
    required this.type,
    required this.title,
    required this.dataKey,
    this.errorKey,
    this.placeholder,
    this.disabled = false,
    this.hidden = false,
    this.icon,
    this.hasShowPassword = false,
    this.isLast = false,
    this.options,
    this.optionsKey,
    this.isInitialValueDisabled = false,
    this.allCaps = false,
    this.maxLength,
    this.onSetValue,
    this.autoFocus = false,
    this.isRequired = false,
    this.requiredLength,

# HTTP Request:

- When doing http requests use request_provider.dart
- When fetching a single endpoint use fetchRequest like:
  - fetchRequest(
    context,
    key: {request key},
    path: {end point path},
    pageSize: 20,
    appendNewData: false,
    forceFetch: true,
    restartPage: true,
    ); - like this if you just initially call it
- When fetching multiple endpoints use fetchRequests like:

  - fetchRequests(
    context,
    [
    Request(
    key: {request key},
    path: {end point path},
    ),
    ],
    true,
    ); You can use the onSuccess of the Request object if you want to create a sequential calls if you need the response data for the next endpoint to call

- When submitting a POST request use submitPostRequest like:
  submitPostRequest(
  context: context,
  key: {request key},
  path: {end point path},
  showToast: { by default it will show a Toast if success or false, if you want to handle the success or error message set this to false}
  showErrorToastForAllError: { by default it will only show the messages if there is an error_message response, if you want show all error even if it's not in the error_message for example you are submitting a post request but you did not use a data-input it is suggested to put this to true},
  extraParameters: {}, // Parameters will came from the data-input but if you have other parameters that is not from the data-input you can put it here
  );

- use auth_provider.dart isSuperAdmin, isAdmin, isSubAdmin, isUser to know what is the current role of the user for hiding/showing widgets depending on the role
