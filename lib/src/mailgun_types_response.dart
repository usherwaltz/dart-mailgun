enum MGResponseStatus { SUCCESS, FAIL, QUEUED }

class MGResponse {
  MGResponseStatus status;
  String message;

  MGResponse(this.status, this.message);
}