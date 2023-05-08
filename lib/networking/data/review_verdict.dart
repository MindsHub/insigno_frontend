enum ReviewVerdict {
  ok("ok"),
  skip("skip"),
  delete("delete"),
  deleteReport("delete_report");

  final String verdict;

  const ReviewVerdict(this.verdict);
}
