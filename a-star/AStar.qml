import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


Item {
    width: 1200
    height: 900

    property var grid: {
        var template = "
        0000000000000000000000
        S111111111111111110101
        0000000000000000010101
        1111111111110111010101
        0000001000100011110101
        0000101010101000000101
        0111100010001111101101
        0111111111111000100001
        0100010001000000111111
        0101010101010000000001
        0101010101011110111101
        00010001000110000011E1
        ".trim();
        var rows = template.split("\n").map(r => r.trim().split(""));
        var columns = [];
        for (var x = 0; x < rows[0].length; x++) {
            var column = [];
            for (var y = 0; y < rows.length; y++) {
                column.push({
                    "position": "%1,%2".arg(x).arg(y),
                    "passable": rows[y][x] != "1",
                    "start": rows[y][x] == "S",
                    "end": rows[y][x] == "E",
                });
            }
            columns.push(column);
        }
        return columns;
    }

    property var queue: {
        "items": [],
        "put": function (priority, value) {
            var inserted = false;
            for (var i = 0; i < this.items.length; i++) {
                if (this.items[i][0] > priority) {
                    this.items.splice(i, 0, [priority, value]);
                    inserted = true;
                    break;
                }
            }
            if (!inserted) {
                this.items.push([priority, value]);
            }
        },
        "get": function () {
            if (this.items.length == 0) {
                return null;
            } else {
                return this.items.shift()[1];
            }
        },
        "empty": function () {
            return this.items.length == 0;
        },
    }

    function neighbors(x, y) {
        var maxX = grid.length;
        var maxY = grid[0].length;
        var cells = [
            [x, y - 1],  // up
            [x + 1, y],  // right
            [x, y + 1],  // down
            [x - 1, y],  // left
        ];
        return cells.filter(function (cell) {
            if (cell[0] < 0 || cell[0] >= maxX) {
                return false;
            } else if (cell[1] < 0 || cell[1] >= maxY) {
                return false;
            } else if (grid[cell[0]][cell[1]].passable) {
                return true;
            }
        });
    }

    property var path: {
        var p = [[0,1], [0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0], [8,0], [9,0], [10,0], [11,0], [12,0], [13,0], [14,0], [15,0], [16,0], [17,0], [18,0], [18,1], [18,2], [18,3], [18,4], [18,5], [17,5], [16,5], [15,5], [14,5], [13,5], [13,4], [12,4], [11,4], [11,5], [11,6], [10,6], [9,6], [9,5], [9,4], [8,4], [7,4], [7,5], [7,6], [6,6], [5,6], [5,5], [5,4], [4,4], [3,4], [2,4], [1,4], [0,4], [0,5], [0,6], [0,7], [0,8], [0,9], [0,10], [0,11], [1,11], [2,11], [2,10], [2,9], [2,8], [3,8], [4,8], [4,9], [4,10], [4,11], [5,11], [6,11], [6,10], [6,9], [6,8], [7,8], [8,8], [8,9], [8,10], [8,11], [9,11], [10,11], [10,10], [10,9], [10,8], [11,8], [12,8], [12,9], [13,9], [14,9], [15,9], [16,9], [17,9], [18,9], [19,9], [20,9], [20,10], [20,11]];
        return p.map(function (item) {return "%1,%2".arg(item[0]).arg(item[1]);});
    }

    property var costs: {
        "0,1": 0,
    }

    Component.onCompleted: {
        queue.put(0, [0, 1]);  // start with "start" node
    }

    function cost(current, next) {
        return 1;
    }

    function heuristic(next) {
        var endX = 20;
        var endY = 11;
        return Math.abs(endX - next[0]) + Math.abs(endY - next[1]);
    }

    function step() {
        if (queue.empty()) {
            return;
        }
        var current = queue.get();
        var currentX = current[0];
        var currentY = current[1];
        current = grid[currentX][currentY];
        neighbors(currentX, currentY).forEach(function (item) {
            var next = grid[item[0]][item[1]];
            var newCost = costs[current.position] + cost([currentX, currentY], item);
            if (costs[next.position] == undefined || newCost < costs[next.position]) {
                costs[next.position] = newCost;
                costsChanged();
                var priority = newCost + heuristic(item);
                queue.put(priority, item);
            }
        });
    }

    Grid {
        columns: grid.length

        anchors.centerIn: parent

        Repeater {
            model: grid.length * grid[0].length

            Rectangle {
                property int gridX: index % grid.length
                property int gridY: index / grid.length
                property var cell: grid[gridX][gridY]
                width: 40
                height: 40
                border.width: 1
                border.color: "gray"
                color: {
                    if (cell.start) {
                        return "steelblue";
                    } else if (cell.end) {
                        return "goldenrod";
                    } else if (path.indexOf(cell.position) != -1) {
                        return "palevioletred";
                    } else if (cell.passable) {
                        return "forestgreen";
                    } else {
                        return "black";
                    }
                }

                Text {
                    text: cell.position
                    font.pixelSize: 10

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 2
                }

                Text {
                    text: costs[cell.position] != undefined ? costs[cell.position] : ""
                    font.pixelSize: 10

                    anchors.centerIn: parent
                }
            }
        }
    }

    RowLayout {
        spacing: 10

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10

        Button {
            text: "Prev Step"
        }

        Slider {
            Layout.fillWidth: true
        }

        Button {
            text: "Next Step"

            onClicked: step()
        }
    }
}
