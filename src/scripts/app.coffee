angular.module "theDoubtersApp", [
  "ngRoute",
  "ngTouch"
  "reformatService"
  "theDoubtersDirective"
  "onFinishRenderDirective"
  "groupController"
  "partyController"
  "mandateController"
]
.config ($routeProvider) ->
  $routeProvider
    .when "/grupper/:group",
      templateUrl: "/upload/tcarlsen/the-doubters/partials/groups.html"
      controller: "groupCtrl"
    .when "/partier",
      templateUrl: "/upload/tcarlsen/the-doubters/partials/parties.html"
      controller: "partyCtrl"
    .when "/mandater",
      templateUrl: "/upload/tcarlsen/the-doubters/partials/mandates.html"
      controller: "mandateCtrl"
   .otherwise
      redirectTo: "/mandater"
