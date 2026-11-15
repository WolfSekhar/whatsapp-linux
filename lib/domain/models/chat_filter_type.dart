/// Category filter types for desktop conversation list.
enum ChatFilterType {
  all('All'),
  unread('Unread'),
  groups('Groups'),
  archived('Archived');

  final String label;
  const ChatFilterType(this.label);
}
