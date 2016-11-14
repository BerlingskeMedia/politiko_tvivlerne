angular.module "theDoubtersDirective", []
  .directive "theDoubters", ($http, $rootScope) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/the-doubters/partials/the-doubters.html"
    link: (scope, element, attr) ->
      $rootScope.page = "groups"
      scope.json = {}
      scope.total =
        doubters: 0
        mandates: 0

      $http.get "/upload/tcarlsen/the-doubters/POLIT2015V1PROFILBERLEKSTRA_OKT16_NOV16.json"
        .then (response) ->
          scope.json = response.data
          scope.total.doubters = Math.round(response.data.Partier["Partivalg FV15 for tvivlere NU"].BASE["vælgere"].total / 1000) * 1000
          scope.total.mandates = response.data.Partier["Partivalg FV15 for tvivlere NU"].BASE.mandater.total
