# Google Apps Script Integration for IT Support Flutter App

This guide shows how to use Google Apps Script as a middle layer for your Flutter app instead of using a service account directly.

## 1. Create the Apps Script

1. Open Google Sheets.
2. Go to `Extensions > Apps Script`.
3. Replace the default code with the script below.

```js
const SPREADSHEET_ID = '1RKJDgvWEvvV90i6HebIgd-MPhr74fHSGKYA-TAw4t0w';

function doGet(e) {
  return handleRequest(e.parameters);
}

function doPost(e) {
  const params = JSON.parse(e.postData.contents || '{}');
  return handleRequest(params);
}

function handleRequest(params) {
  const action = params.action || '';
  const sheet = params.sheet || '';
  const index = params.index !== undefined ? parseInt(params.index, 10) : null;
  const payload = params.payload || {};

  try {
    switch (action) {
      case 'list':
        return jsonResponse(listRows(sheet));
      case 'add':
        return jsonResponse(addRow(sheet, payload));
      case 'update':
        return jsonResponse(updateRow(sheet, index, payload));
      case 'delete':
        return jsonResponse(deleteRow(sheet, index));
      default:
        return jsonResponse({ success: false, error: 'Unknown action' });
    }
  } catch (error) {
    return jsonResponse({ success: false, error: error.toString() });
  }
}

function getSheet(sheetName) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  let sheet = ss.getSheetByName(sheetName);
  if (!sheet) {
    sheet = ss.insertSheet(sheetName);
    const headers = getHeaders(sheetName);
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  }
  return sheet;
}

function getHeaders(sheetName) {
  switch (sheetName) {
    case 'CM':
    case 'PM':
      return ['Title', 'Description', 'ImagePath'];
    case 'WiFi':
      return ['SSID', 'Password'];
    case 'Mic':
      return ['Name', 'Channel'];
    default:
      return ['Title', 'Description'];
  }
}

function listRows(sheetName) {
  const sheet = getSheet(sheetName);
  const range = sheet.getDataRange();
  const values = range.getValues();
  const rows = values.slice(1).map(function(row) {
    return row.map(function(cell) {
      return cell === undefined || cell === null ? '' : cell.toString();
    });
  });
  return { success: true, rows: rows };
}

function addRow(sheetName, payload) {
  const sheet = getSheet(sheetName);
  const headers = getHeaders(sheetName);
  const row = headers.map(function(header) {
    return payload[header] || '';
  });
  sheet.appendRow(row);
  return { success: true };
}

function updateRow(sheetName, index, payload) {
  if (index === null || index < 0) {
    throw new Error('Invalid index');
  }
  const sheet = getSheet(sheetName);
  const headers = getHeaders(sheetName);
  const rowNumber = index + 2;
  const row = headers.map(function(header) {
    return payload[header] || '';
  });
  sheet.getRange(rowNumber, 1, 1, row.length).setValues([row]);
  return { success: true };
}

function deleteRow(sheetName, index) {
  if (index === null || index < 0) {
    throw new Error('Invalid index');
  }
  const sheet = getSheet(sheetName);
  sheet.deleteRow(index + 2);
  return { success: true };
}

function jsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}
```

## 2. Deploy the Apps Script as a Web App

1. In Apps Script, click `Deploy > New deployment`.
2. Select `Web app`.
3. Set `Who has access` to `Anyone` or `Anyone with the link`.
4. Deploy and copy the Web App URL.

## 3. Call the Web App from Flutter

Use HTTP requests from your Flutter app to perform actions.

### Example request structure

- `action`: `list`, `add`, `update`, or `delete`
- `sheet`: `CM`, `PM`, `WiFi`, or `Mic`
- `index`: row index (0-based for update/delete)
- `payload`: object with values matching the sheet headers

### Example Dart helper

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String appsScriptUrl = 'https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec';

Future<Map<String, dynamic>> callSheetApi(String action, String sheet, {int? index, Map<String, dynamic>? payload}) async {
  final body = jsonEncode({
    'action': action,
    'sheet': sheet,
    'index': index,
    'payload': payload ?? {},
  });

  final response = await http.post(
    Uri.parse(appsScriptUrl),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

### Sample payload for `CM` / `PM`

```dart
{
  'Title': 'Example note',
  'Description': 'Fix printer',
  'ImagePath': '/storage/emulated/0/Pictures/it_note.jpg',
}
```

### Sample payload for `WiFi`

```dart
{
  'SSID': 'Office-WiFi',
  'Password': 'MyPassword123',
}
```

### Sample payload for `Mic`

```dart
{
  'Name': 'Room A',
  'Channel': '5',
}
```

## 4. Benefits of Apps Script approach

- ไม่มีไฟล์ `credentials.json` ในแอป
- ไม่ต้องใช้แพ็กเกจ `googleapis` หรือ `googleapis_auth`
- สามารถใช้งานผ่าน HTTP ได้จากอุปกรณ์ทุกชนิด

## 5. Notes

- ถ้าต้องการให้แก้โค้ด `lib/main.dart` ให้ใช้ Apps Script แทนด้วย ผมสามารถช่วยอัปเดตให้ได้เลย
- หากต้องการจำกัดการเข้าถึงให้ปลอดภัยขึ้น ให้พิจารณาใช้ `Anyone with the link` และตรวจสอบค่าพารามิเตอร์ใน Apps Script ให้เข้มงวด
