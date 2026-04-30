const SHEET_ID = "1yGuP7IcjnG_jbua4KH57D_68VaEhwOPhMT2yJkxG838";

function doPost(e) {
  try {
    if (!e || !e.postData || !e.postData.contents) {
      Logger.log('doPost called without postData; call via HTTP POST or use testDoPost()');
      return ContentService.createTextOutput('No postData; use HTTP POST or testDoPost').setMimeType(ContentService.MimeType.TEXT);
    }

    const payload = JSON.parse(e.postData.contents || "{}");
    const ss = SpreadsheetApp.openById(SHEET_ID);
    const sheet = ss.getSheetByName("Sheet1") || ss.getSheets()[0];
    const ts = new Date();

    // If you receive a single word test:
    if (payload.word) {
      sheet.appendRow([ts, payload.word]);
      return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
    }

    // If payload contains players (SubmitGame format)
    if (payload.players && Array.isArray(payload.players)) {
      payload.players.forEach(function(p) {
        const cards = (p.cards || []).join(" | ");
        const power = (p.scores && p.scores[1]) ? p.scores[1] : "";
        const hand  = (p.scores && p.scores[3]) ? p.scores[3] : "";
        sheet.appendRow([ts, p.color || "", cards, power, hand, JSON.stringify(p.scores || {})]);
      });
      return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
    }

    // Fallback: append full JSON
    sheet.appendRow([ts, JSON.stringify(payload)]);
    return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
  } catch (err) {
    Logger.log("doPost error: " + err);
    return ContentService.createTextOutput("Error: " + err).setMimeType(ContentService.MimeType.TEXT);
  }
}

function doGet(e) {
  return ContentService.createTextOutput('Web app deployed. Use POST to send data.');
}

function testDoPost() {
  const fake = {
    postData: {
      contents: JSON.stringify({ word: 'test-from-editor' })
    }
  };
  const res = doPost(fake);
  Logger.log('testDoPost result: ' + (res && res.getContent ? res.getContent() : JSON.stringify(res)));
}