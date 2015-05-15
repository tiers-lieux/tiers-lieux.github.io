module = angular.module("map.controllers", [])

module.run(['$anchorScroll', ($anchorScroll) ->
  $anchorScroll.yOffset = 50
])

module.controller("ImaginationProjectsMapCtrl", ($scope, $compile, $anchorScroll, $timeout, $location, leafletData, leafletEvents, geocoderService, Project, ProjectSheet) ->
    """
    This controller is made to be child of ProjectListCtrl where it watches for update in $scope.projectsheets list
    Upon update, it rebuilds its marker base
    """
    $scope.rebuildMarkers = ()->
        #console.log(" Updating projectsheets : new ="+newVal+" old = "+oldVal)
        $scope.markers = new Array()
        angular.forEach($scope.projectsheets, (ps)->
            # Either get LatLng directly, or from address_locality ?
            marker = 
            {
                lat: ps.project.location.geo.coordinates[1]
                lng: ps.project.location.geo.coordinates[0]
                message: '<div ng-include="\'views/map/marker_card.html\'" class= "boxes boxes-small"></div>'
                data:
                        title: ps.project.title
                        baseline: ps.project.baseline
                        description: ps.project.description
                        cover: ps.cover
                        id: ps.project.id
                        slug: ps.project.slug

                icon:
                        type: 'awesomeMarker'
                        prefix: 'fa'
                        # icon: marker.category.icon_name
                        markerColor: "blue"
                        iconColor: "white"
            }
            $scope.markers.push(marker)
            )

    $scope.gotoAnchor = (x) ->
        newHash = 'anchor' + x
        if $location.hash() != newHash
            $location.hash('anchor' + x)
        else
            $anchorScroll()

    console.log("loadind map, projectsheets ?", $scope.projectsheets)

    angular.extend($scope,
        defaults :
            scrollWheelZoom: false # Keep the scrolling working on the page, not in the map
            maxZoom: 14
            minZoom: 1
            path:
                weight: 10
                color: '#800000'
                opacity: 1
        center:
            lat: 46.43
            lng: 2.35
            zoom: 5
        markers : []
    )
    $scope.rebuildMarkers()
    console.log("rebuilt markers", $scope.markers)  
    # Watch for update in projectsheets
    $scope.$watch(
            ()->
                return $scope.projectsheets
            ,(newVal, oldVal) ->
                if newVal != oldVal
                    $scope.rebuildMarkers() 
                    console.log("rebuilt markers", $scope.markers)  

    )

    # Catch popup opening, format template with current data and open popup
    $scope.$on('leafletDirectiveMarker.popupopen', (event, leafletEvent) ->
            newScope = $scope.$new()
            angular.extend(newScope,
                    marker: $scope.markers[leafletEvent.markerName]
            )
            # FIXME : timeout needed to wait complete fetching of markers popup template
            $timeout(()->
                $compile(leafletEvent.leafletEvent.popup._contentNode)(newScope)
            ,300)
            # console.log(" clicking marker", newScope)
    )

    # $scope.$on("leafletDirectiveMap.click", (event, args) ->
    #     if $scope.spottedProfile
    #         marker = $scope.markers[$scope.spottedProfile.id]
    #         marker.icon = marker.icon_standard
    #         $scope.spottedProfile = null
    #     $scope.showMemberInfo = false
    # )
)
