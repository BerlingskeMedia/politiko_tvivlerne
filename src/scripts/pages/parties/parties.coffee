angular.module "partyController", []
  .controller "partyCtrl", ($rootScope, $scope, $timeout, $window, $filter) ->
    procentConverter = (d) -> parseFloat d.procenter.total.replace ",", "."

    $rootScope.page = "parties"

    retina = true if $window.devicePixelRatio > 1
    total = []
    doubters = []
    data = []
    maxPercent = 0
    minColWidth = 228
    padding =
      top: 60
    partyColors =
      "ø": "#731525"
      f: "#9c1d2a"
      a: "#e32f3b"
      b: "#e52b91"
      c: "#0f854b"
      v: "#0f84bb"
      o: "#005078"
      i: "#ef8535"
      k: "#f0ac55"
    svg = d3.select "svg"
    tip = d3.tip()
      .attr "class", "d3-tip"
      .html (d) ->
        total = $filter('number')(d.total, 1)
        doubters = $filter('number')(d.doubters.text, 1)
        html = "<p>Partiets tilslutning: #{total}%</p>"
        html+= "<p>Heraf er #{doubters}% i tvivl</p>"

        return html
    svg.call tip

    for key, value of $scope.json.Partier["Partivalg NU"]
      continue if key is "BASE"

      party = key
      words = party.split " "

      if words[words.length - 1] is "tvivlere"
        words.splice (words.length - 1), 1
        party = words.join " "

        doubters[party] = procentConverter value
      else
        total[party] = procentConverter value

    for key, value of total
      total[key] += doubters[key]
      doubters[key] =
        value: doubters[key]
        text: doubters[key] / total[key] * 100

      data.push
        party: key
        total: total[key]
        doubters: doubters[key]

      maxPercent = total[key] if total[key] > maxPercent

    render = ->
      svgWidth = d3.select("ng-view")[0][0].offsetWidth
      columnCount = parseInt(svgWidth / minColWidth)
      colWidth = svgWidth / columnCount
      rowCount = Math.ceil(data.length / columnCount)
      svgHeight = colWidth * rowCount + (padding.top * 2)
      maxRadius = (colWidth - padding.top) / 2
      xPosition = colWidth / 2
      yPosition = colWidth / 2
      logoSize = 20

      # d3 components
      radius = d3.scale.sqrt().domain([0, maxPercent]).range([10, maxRadius])

      svg
        .attr "width", "#{svgWidth}px"
        .attr "height", "#{svgHeight}px"

      parties = svg.selectAll(".parties").data(data)

      parties
        .enter()
          .append "g"
            .attr "class", (d) -> "parties #{d.party}"
            .attr "transform", (d, i) ->
              x = xPosition
              y = yPosition
              xPosition += colWidth
              o = i + 1

              if o % columnCount is 0 and i isnt 0
                yPosition += colWidth
                xPosition = colWidth / 2

              return "translate(#{x}, #{y})"
            .on "mouseover", (d) -> tip.show(d)
            .on "mouseout", tip.hide

      totalCircles = parties.append "circle"
        .attr "class", "total"
        .attr "r", (d) -> radius(d.total)
        .attr "fill", (d) -> partyColors[d.party]

      doubterCircles = parties.append "circle"
        .attr "class", "doubter"
        .attr "r", (d) -> radius(d.doubters.value)
        .attr "cx", (d) ->
          x = radius(d.total) * Math.cos(15)
          x2 = radius(d.doubters.value) * Math.cos(15)

          return x - x2
        .attr "cy", (d) ->
          y = radius(d.total) * Math.sin(15)
          y2 = radius(d.doubters.value) * Math.sin(15)

          return y - y2

      logos = parties.append "image"
        .attr "class", "logo"
        .attr "width", logoSize
        .attr "height", logoSize
        .attr "x", -logoSize / 2
        .attr "y", -colWidth / 2
        .attr "xlink:href", (d) ->
          return "/upload/tcarlsen/the-doubters/img/#{d.party}_small@2x.png" if retina
          return "/upload/tcarlsen/the-doubters/img/#{d.party}_small.png"

    $window.onresize = ->
      svg.selectAll("*").remove()
      render()

    render()
