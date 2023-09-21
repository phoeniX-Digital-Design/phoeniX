Hazard_Forward_Unit
==================
|        Signal       |   Width  | Direction |                    Description                    |
|:-------------------:|:--------:|:---------:|:-------------------------------------------------:|
|     source_index    |  [4 : 0] |   input   |     Index of data source requiring forwarding     |
| destination_index_1 |  [4 : 0] |   input   |   Index of the first data option for forwarding   |
| destination_index_2 |  [4 : 0] |   input   |   Index of the second data option for forwarding  |
| destination_index_3 |  [4 : 0] |   input   |   Index of the third data option for forwarding   |
|        data_1       | [31 : 0] |   input   |   Value of the first data option for forwarding   |
|        data_2       | [31 : 0] |   input   |   Value of the second data option for forwarding  |
|        data_3       | [31 : 0] |   input   |   Value of the third data option for forwarding   |
|       enable_1      |     1    |   input   |  Validity of the first data option for forwarding |
|       enable_2      |     1    |   input   | Validity of the second data option for forwarding |
|       enable_3      |     1    |   input   |  Validity of the third data option for forwarding |
|    forward_enable   |     1    |   output  |  Enable signal for controlling forwarding action  |
|     forward_data    | [31 : 0] |   output  |         Data to be forwarded to the source        |
