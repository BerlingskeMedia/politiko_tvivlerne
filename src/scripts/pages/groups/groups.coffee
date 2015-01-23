angular.module "groupController", []
  .controller "groupCtrl", ($rootScope, $scope, $window, $timeout, $routeParams, reformatter) ->
    procentConverter = (d) -> parseFloat d.data.procenter.total.replace ",", "."

    $rootScope.page = "groups"
    $scope.activeGroup = $routeParams.group
    $scope.groups = reformatter.format $scope.json.Tvivlere

    svg = d3.select "svg"

    render = (index) ->
      liTop = d3.select(".groups .index-#{index}")[0][0].offsetTop
      liHeight = d3.select(".groups .index-#{index}")[0][0].offsetHeight
      svgWidth = d3.select("ng-view")[0][0].offsetWidth
      svgWidth -= 180 if angular.element($window)[0].innerWidth > 550
      svgHeight = 310
      data = $scope.groups[index].subs
      dataCount = data.length
      sum = d3.sum data, (d) -> procentConverter d
      yPosition = 5
      barMargin =
        left: if svgWidth >= 540 then 100 else 0
        right: if svgWidth >= 540 then 100 else 0
        bottom: 10
      barWidth = svgWidth - barMargin.left - barMargin.right
      rangeMax = svgHeight - (barMargin.bottom * (dataCount - 1))

      # d3 components
      yScale = d3.scale.linear()
        .domain [0, sum]
        .range [0, rangeMax - 10]

      svg
        .attr "width", "#{svgWidth}px"
        .attr "height", "#{svgHeight}px"
        .attr "float", "left"

      entries = svg.selectAll(".entry").data(data)

      entries
        .enter()
          .append "g"
            .attr "class", "group-entry"
            .attr "transform", (d) ->
              y = yPosition
              yPosition += yScale(procentConverter(d)) + barMargin.bottom

              return "translate(10, #{y})"
            .attr "data-x", (d, i) ->
              yPosition = 0 if i is 0

              y = yPosition
              yPosition += yScale(procentConverter(d)) + barMargin.bottom

              return y
            .on "mouseover", ->
              groupEle = angular.element(this)
              textEle = groupEle.find("text")
              classList = textEle[0].attributes[0].nodeValue

              if classList.indexOf("popup") isnt -1
                textEle.attr "class", "label popup"

                BBox = textEle[0].getBBox()

                d3.select(this).insert "rect", "text"
                  .attr "class", "overlay"
                  .attr "x", BBox.x - 10
                  .attr "y", BBox.y
                  .attr "height", BBox.height
                  .attr "width", BBox.width + 20

            .on "mouseout", ->
              textEle = angular.element(this).find("text")
              classList = textEle[0].attributes[0].nodeValue

              if classList.indexOf("popup") isnt -1
                d3.select(this).select(".overlay").remove()
                textEle.attr "class", "label popup hide"

      columns = entries.append "rect"
        .attr "class", "column"
        .attr "x", barMargin.left
        .attr "height", (d) -> yScale(procentConverter(d))
        .attr "width", barWidth

      if svgWidth >= 540
        pointers = entries.append "path"
          .attr "class", "pointer"
          .attr "d", (d) ->
            liPos = liTop - @parentNode.getAttribute("data-x") + (liHeight / 3)

            return "M0,#{liPos}L#{barMargin.left},0L#{barMargin.left},#{yScale(procentConverter(d))}z"

      texts = entries.append "text"
        .attr "class", "label"
        .attr "x", (barWidth / 2) + barMargin.left
        .attr "y", (d) -> yScale(procentConverter(d)) / 2
        .attr "dy", 6.2
        .attr "text-anchor", "middle"
        .text (d) -> "#{d.label.toUpperCase()} #{d.data.procenter.total.replace('%', '')} pct."
        .classed "popup hide", (d) -> yScale(procentConverter(d)) < 20

    $window.onresize = ->
      svg.selectAll("*").remove()
      render $scope.activeGroup

    $scope.$on "ngRepeatFinished", ->
      render $scope.activeGroup
