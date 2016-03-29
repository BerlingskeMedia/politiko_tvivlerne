angular.module "mandateController", []
  .controller "mandateCtrl", ($rootScope, $scope, $window) ->
    $rootScope.page = "mandates"

    svg = d3.select "svg"
    mandates = $scope.json.Partier["Partivalg FV15 for tvivlere NU"].BASE.mandater.total


    d3.xml "/upload/tcarlsen/the-doubters/img/folketingssal.svg", "application/xml", (xml) ->
      hall = svg.node().appendChild xml.getElementsByTagName("svg")[0]
      i = 1

      while i <= mandates
        d3.select "#man#{i}"
          .attr "fill", "#e6c876"

        i++

      render()

    render = ->
      svgCenter = d3.select("ng-view")[0][0].offsetWidth / 2
      text = svg.append "text"
        .attr "class", "mandates"
        .attr "y", 20

      text.append "tspan"
        .attr "x", svgCenter + 15
        .attr "dy", 0
        .attr "text-anchor", "middle"
        .text mandates

      text.append "tspan"
        .attr "x", svgCenter + 15
        .attr "dy", 22
        .attr "text-anchor", "middle"
        .text "tvivler"

      text.append "tspan"
        .attr "x", svgCenter + 15
        .attr "dy", 22
        .attr "text-anchor", "middle"
        .text "mandater"

      $window.onresize = ->
        svg.select("text.mandates").remove()
        render()
