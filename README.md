# Description

Remote Logging Library to log a device from remote

## Logging Platform

* Google Cloud Logging
* Betterstack

### Google Cloud Logging

#### Constructor

| Parameter      | Type                 | Description                          |
|----------------|----------------------|--------------------------------------|
| serviceAccount | Map<String, dynamic> | Secret Key Get From Google Cloud.    |
| env            | String               | Environment for classification logs. |

### Betterstack

#### Constructor

| Parameter   | Type   | Description                                                                   |
|-------------|--------|-------------------------------------------------------------------------------|
| sourceToken | String | Access token to post the log through API. Fetched from Betterstack Dashboard. |


### Method

#### Init

Call this function to init a remote logging service after create a constructor.

### Write Remote Log

Write log into specific platform remote logging.

| Parameter | Type                | Description                  |
|-----------|---------------------|------------------------------|
| level     | Level               | Level to identify the log.   |
| message   | String              | The message log.             |
| labels    | Map<String, String> | The nested value of the log. |

### Add Default Label

Add default label value for added into a log.

| Parameter | Type                | Description                                                   |
|-----------|---------------------|---------------------------------------------------------------|
| labels    | Map<String, String> | The nested value that want set as a default value of the log. |

### Remove Default Label

Remove label from default label

| Parameter | Type           | Description                                       |
|-----------|----------------|---------------------------------------------------|
| labels    | List<String>   | The label key want to remove from default labels. |
