# LullabAI API Contract Differences

**Live vs Current (New Server)**

## 1. Overview

* **Live API (Production)**: `https://api.lulllabai.com/api/`
* **Current API (New server)**: `http://3.208.56.202:9010/api/`
* **Problem**:
  The **response structure and sometimes status codes have changed** on the new server.
  The **iOS frontend is still implemented against the *live* API contract**, so these changes are causing:

  * JSON parsing failures
  * Crashes (`Fatal error: Unexpectedly found nil while unwrapping an Optional value`)
  * 404 errors on some endpoints

This document lists **each API**, shows **Live vs Current response**, and explains **what changed** and **frontend impact**.

---

## 2. High-level Change Summary
| API Name          | Endpoint Path              | Live Status | Current Status | Contract Compatible? | Notes                                                      |
| ----------------- | -------------------------- | ----------- | -------------- | -------------------- | ---------------------------------------------------------- |
| Register          | `/signup/`                 | 201 / JSON  | 201 / JSON     | ❌ No                 | Response shape & fields changed                            |
| Verify OTP        | `/verify-otp/`             | 200 / JSON  | 200 / JSON     | ❌ No                 | Fields changed, user object removed                        |
| Login (new)       | `/login/`                  | N/A         | 200 / JSON     | ✅ New API            | New endpoint, not in live                                  |
| Get Voices        | `/voices/`                 | 200 / JSON  | 200 / JSON     | ❌ No                 | Wrapper (`status`, `data`) removed                         |
| Create Voice      | `/voice/create/`           | 500 error   | 201 / JSON     | ❌ No                 | Now works but response structure differs from expectations |
| Get Home Stories  | `/get_home_stories`        | 200 / JSON  | 404            | ❌ No                 | Endpoint not implemented / path changed                    |
| Get Random Story  | `/random_story/`           | 200 / JSON  | 404            | ❌ No                 | Endpoint not implemented / path changed                    |
| Get Stories       | `/stories/`                | 200 / JSON  | Client error   | ❓ Maybe changed      | Live accepted GET with body; new server rejects            |
| Get Categories    | `/categories/`             | 200 / JSON  | Not tested     | ❓ Unknown            | Live contract known, new not confirmed                     |
| Get History       | `/history/`                | 200 / JSON  | 200 / JSON     | ❌ No                 | Wrapper (`status`, `data`) removed                         |
| Get Bookmark List | `/get_collection_history/` | 200 / JSON  | 404            | ❌ No                 | Endpoint not implemented / path changed                    |
| Get Terms/Policy  | `/get_terms_and_policy/`   | 200 / JSON  | 404            | ❌ No                 | Endpoint not implemented / path changed                    |

---

## 3. Detailed API Differences

### 3.1 Register – `POST /signup/`

**Live API (Production)**
`https://api.lulllabai.com/api/signup/`

```json
{
  "status": 1,
  "data": {
    "verification_code": "8509",
    "user": {
      "email": "samir@gmail.com",
      "id": 124,
      "profile_image": "https://lullabai.s3.amazonaws.com/anzali_resources/image(1).png",
      "name": "samir raval",
      "verified": false
    }
  }
}
```

**Current API (New Server)**
`http://3.208.56.202:9010/api/signup/`

```json
{
  "message": "Signup successful.",
  "verification_code": "4859",
  "email_status": "Verification email sent to your email address.",
  "user": {
    "email": "samir@test.com",
    "id": 125,
    "name": "samir test",
    "verified": false
  }
}
```

**Changes**

* **Removed**: top-level `"status"` field.
* **Removed**: `"data"` wrapper object.

  * Live: `data.user`, `data.verification_code`
  * Current: `user`, `verification_code` directly at root.
* **Removed**: `user.profile_image`.
* **Added**: `"message"` and `"email_status"` fields.

**Frontend Impact**

* Existing app likely decodes/reads:

  * `status` (Int)
  * `data.user` and `data.verification_code`
  * `user.profile_image` (used for default avatar)
* With the new response:

  * Decoding of `status` and `data` fails → optional unwrapping crash.
  * No `profile_image` → needs null-safe handling or backend to re-add field.

---

### 3.2 Verify OTP – `POST /verify-otp/`

**Live API**

```json
{
  "status": 1,
  "data": {
    "tokens": {
      "refresh": "<jwt-refresh>",
      "access": "<jwt-access>"
    },
    "user": {
      "email": "samir@gmail.com",
      "id": 124,
      "name": "samir raval",
      "verified": true
    }
  }
}
```

**Current API**

```json
{
  "success": true,
  "message": "OTP verified successfully.",
  "tokens": {
    "refresh": "<jwt-refresh>",
    "access": "<jwt-access>"
  }
}
```

**Changes**

* **`status` (Int)** → replaced by **`success` (Bool)** and `"message"`.
* **Removed**: `"data"` wrapper.
* **Removed**: `"user"` object from response. Only tokens are returned now.
* `tokens` moved from `data.tokens` → top-level `tokens`.

**Frontend Impact**

* Frontend currently expects:

  * `status == 1`
  * `data.user` and `data.tokens`
* With new response:

  * Parsing `data` fails.
  * No `user` object → code relying on updated user profile (e.g. `verified` flag) will break.

---

### 3.3 Login – `POST /login/` (New on current server)

**Live API**
No login endpoint was provided/used in the previous live flow (signup + verify OTP was likely the only path).

**Current API**

```json
{
  "message": "Login successful.",
  "user": {
    "email": "samir@test.com",
    "id": 125,
    "name": "samir test",
    "verified": true
  },
  "tokens": {
    "refresh": "<jwt-refresh>",
    "access": "<jwt-access>"
  }
}
```

**Notes**

* This is a **new** endpoint/flow compared to the live environment.
* Response format is similar to the new verify-otp style (top-level `user` and `tokens`, plus `message`).

**Frontend Impact**

* No impact on existing live app (not used there).
* For new app versions, a dedicated model is needed for this new contract.

---

### 3.4 Get Voices – `GET /voices/`

**Live API**

```json
{
  "status": 1,
  "data": {
    "voices": [
      // ...
    ]
  }
}
```

**Current API (before voice creation)**

```json
{
  "voices": []
}
```

**Current API (after voice creation)**

```json
{
  "voices": [
    {
      "id": 152,
      "voice": "http://3.208.56.202:9010/static/recording_jJZrlAX.wav",
      "order": 0,
      "name": "sssss",
      "user": 125
    }
  ]
}
```

(And debug print later shows a Swift dictionary like `["voices": ..., "status": "1"]` but the **actual JSON string** only contains `voices`.)

**Changes**

* **Removed**: `"status"` and `"data"` wrapper.
* `voices` moved from `data.voices` → top-level `voices`.
* Voice item fields look broadly compatible (id, name, voice, etc).

**Frontend Impact**

* Existing code expects:

  * `status` at root.
  * `data.voices` array.
* Now it only receives `voices` at root:

  * Model decoding / manual parsing fails.
  * This directly caused the crash:
    `Fatal error: Unexpectedly found nil while unwrapping an Optional value` in `YourVoiceVC.swift:55`.

---

### 3.5 Create Voice – `POST /voice/create/`

**Live API**

* Request returned **500** with parse error:

  * `"JSON text did not start with array or object..."` (backend issue).

**Current API**

```json
{
  "voice": {
    "id": 152,
    "voice": "http://3.208.56.202:9010/static/recording_jJZrlAX.wav",
    "order": 0,
    "name": "sssss",
    "user": 125
  },
  "message": "Voice created successfully."
}
```

**Changes**

* Endpoint now **successfully creates** a voice and returns it.
* Response structure is **new and not aligned** with any previous live contract (which was failing anyway).

**Frontend Impact**

* Frontend code may:

  * Be written around the assumption that GET `/voices/` will be refreshed after creation and that the live API always wraps in `status` + `data`.
  * Not yet handle `voice` + `message` structure directly.

---

### 3.6 Get Home Stories – `GET /get_home_stories`

**Live API**

```json
{
  "status": 1,
  "data": {
    "featured": [ ... ],
    "recent":   [ ... ],
    "sweet":    [ ... ]
  }
}
```

**Current API**

* Request: `GET http://3.208.56.202:9010/api/get_home_stories`
* Response: **404 – resourceNotFound**

**Changes**

* Endpoint returns **404** instead of a JSON payload.
* Either:

  * Not implemented on the new server, or
  * Path / method has changed.

**Frontend Impact**

* Home screen relying on `featured`, `recent` and `sweet` lists will:

  * Fail to load.
  * Potentially show empty states or errors, depending on current error handling.

---

### 3.7 Get Random Story – `GET /random_story/`

**Live API**

```json
{
  "status": 1,
  "data": {
    "story": {
      // full story object
    }
  }
}
```

**Current API**

* Request: `GET http://3.208.56.202:9010/api/random_story/`
* Response: **404 – resourceNotFound**

**Changes**

* Endpoint not available / not implemented on current server.

**Frontend Impact**

* Any feature invoking random story (e.g. “Play random story”) will fail.

---

### 3.8 Get Categories – `GET /categories/`

**Live API**

```json
{
  "status": 1,
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Stories",
        "image": ".../categories/stories.png",
        "order": 0,
        "status": true,
        "featured": false
      },
      {
        "id": 2,
        "name": "Poems",
        ...
      },
      {
        "id": 3,
        "name": "Lullabies",
        ...
      }
    ]
  }
}
```

**Current API**

* Not captured/tested in the provided logs.

**Changes**

* **Unknown** for now; needs confirmation.

**Frontend Impact**

* If the current server changes wrapper (`status`, `data`) as with other endpoints, the same parsing issues will occur.
* Recommended: backend keeps existing contract (status + data.categories) or FE is updated.

---

### 3.9 Get Stories by Category – `GET /stories/`

**Live API**

* Request (GET with body param):

  ```http
  GET /api/stories/
  Body: { "category": "1" }
  ```

* Response:

  ```json
  {
    "status": 1,
    "data": {
      "stories": [ ... ]
    }
  }
  ```

**Current API**

* Same URL used: `GET http://3.208.56.202:9010/api/stories/`
* iOS sends body with `"category": "1"` and gets:

  * `Alamofire.AFError.urlRequestValidationFailed(bodyDataInGETRequest)`
  * Status code: 0 (client-side validation failure, request not sent).

**Changes (probable)**

* New backend likely expects:

  * `category` as **query param** (`/stories/?category=1`), or
  * Different method (e.g. `POST`).
* Given the pattern, the response format may also have dropped `status`/`data`.

**Frontend Impact**

* Current GET-with-body approach no longer valid.
* Even if endpoint exists, app must:

  * Use the correct HTTP method + param placement.
  * Adjust to any response shape changes.

---

### 3.10 Get History – `GET /history/`

**Live API**

```json
{
  "status": 1,
  "data": {
    "history": []
  }
}
```

**Current API**

```json
{
  "history": []
}
```

**Changes**

* **Removed**: `status` and `data` wrapper.
* `history` moved from `data.history` → top-level `history`.

**Frontend Impact**

* Existing app expects:

  * `status` == 1
  * `data.history`
* Now only `history` exists:

  * Parsing fails or returns nil.
  * Any forced unwrap on `data` triggers crashes.

---

### 3.11 Get Bookmark List – `GET /get_collection_history/`

**Live API**

```json
{
  "status": 1,
  "data": {
    "history": []
  }
}
```

**Current API**

* Request: `GET http://3.208.56.202:9010/api/get_collection_history/` with param `"title": ""`
* Response: **404 – resourceNotFound**

**Changes**

* Endpoint not available on new server.

**Frontend Impact**

* Bookmark/collection screen will not work (404).

---

### 3.12 Get Terms & Privacy Policy – `GET /get_terms_and_policy/`

**Live API**

* Type = `"policy"`:

  ```json
  {
    "status": 1,
    "data": {
      "story": {
        "id": 2,
        "title": "Privacy Policy",
        "type": "Policy",
        "file": "<pdf-url>",
        "description": "<html>...</html>"
      }
    }
  }
  ```

* Type = `"terms"`:

  ```json
  {
    "status": 1,
    "data": {
      "story": {
        "id": 1,
        "title": "Terms & Conditions",
        "type": "Terms",
        "file": "<pdf-url>",
        "description": "The following Terms and Conditions ..."
      }
    }
  }
  ```

**Current API**

* Requests:

  ```http
  GET /api/get_terms_and_policy/?type=policy
  GET /api/get_terms_and_policy/?type=terms
  ```

* Both return: **404 – resourceNotFound**

**Changes**

* Endpoint not present / not configured on new server.

**Frontend Impact**

* Privacy Policy and Terms & Conditions screens cannot load from backend.
* If the app relies on these APIs at runtime, the user will see an error or empty screen.

---

## 4. Summary & Recommendations

1. **Most responses on the new server have changed in shape:**

   * Live APIs consistently used:
     `{"status": 1, "data": { ... }}`
   * New APIs mostly drop `"status"` and `"data"` and move inner properties to the root, or rename fields (`status` → `success`, add `message`, etc.).

2. **Several critical endpoints now return 404 on the new server:**

   * `/get_home_stories`
   * `/random_story/`
   * `/get_collection_history/`
   * `/get_terms_and_policy/`

3. **Frontend is still implemented based on the *live* contract:**

   * Expects `status` (Int) and `data` wrapper.
   * Expects nested objects (`data.user`, `data.voices`, `data.history`, etc.).
   * This mismatch directly explains the crashes and failures after pointing the app to the new server.

### Options

* **Option A (Recommended for quick stabilization):**
  Update the **new backend** to match the **existing live API contract**:

  * Keep `status` + `data` structure.
  * Preserve field names and presence (e.g. `profile_image`).
  * Re-implement missing endpoints (`get_home_stories`, `random_story`, `get_collection_history`, `get_terms_and_policy`) with the same responses as live.
  * This minimizes frontend changes and risk.

* **Option B:**
  Keep the new backend contract and **refactor the frontend**:

  * Update all response models and parsing logic to the new structures.
  * Add robust error handling for missing fields and 404s.
  * This will take more frontend effort and careful regression testing.

