abstract class SearchState {}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchLoaded extends SearchState {
  final List<dynamic> cities;
  SearchLoaded(this.cities);
}
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
