abstract final class ExternalUrls {
  // sanalyer has no public status page; status polling and links are off.
  static const bool serviceStatusEnabled = false;
  static const String serviceStatus = 'https://sanalyer.com';
  static const String serviceStatusHistory = serviceStatus;
  static const String fluxerMarketing = 'https://sanalyer.com';
  // sanalyer has no patch notes page; the What's new entry is hidden.
  static const bool patchNotesEnabled = false;
  static const String fluxerPatchNotes = '$fluxerMarketing/patch-notes';
  static const String fluxerDownload = 'https://sanalyer.com/indir';
}
