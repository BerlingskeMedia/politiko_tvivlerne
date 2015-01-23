angular.module "onFinishRenderDirective", []
  .directive "onFinishRender", ($timeout) ->
    restrict: "A"
    link: (scope, element, attr) ->
      if scope.$last
        $timeout -> scope.$emit "ngRepeatFinished"
