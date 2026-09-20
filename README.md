# Flutter Shop App

![CI](https://github.com/henibenamara/flutter-shop-app/actions/workflows/ci.yml/badge.svg)

A shop client that has to deal with what real apps deal with: a login that decides where you can navigate, a paged list you can search as you type, network errors, and data that must survive without a connection. It talks to the free [DummyJSON](https://dummyjson.com) API, so there is no backend to run.

It is the bigger sibling of [flutter-clean-architecture](https://github.com/henibenamara/flutter-clean-architecture): same layering, more moving parts.

## Features

- **Sign in.** The session is stored on the device and restored on the next launch. Demo credentials: `emilys` / `emilyspass`.
- **Catalog.** Grid with infinite scroll, pull to refresh and search that waits for you to stop typing.
- **Product page.** Image carousel, discount, rating and stock.
- **Favorites.** Saved on the device with the whole product, so the list opens offline.
- **Light and dark theme** (Material 3), responsive grid from phone to desktop.

## Structure

Feature-first, with three layers inside each feature. Dependencies point inwards: presentation and data depend on domain, and domain depends on nothing.

```
lib/
├── core/                    Result, failures, exceptions, http helpers
├── features/
│   ├── auth/                login, restore session, logout
│   ├── products/            list, search, paging, detail
│   └── favorites/           offline favorites
├── injection.dart           get_it wiring (the only file that knows every class)
├── router.dart              go_router and the auth redirect rules
└── app.dart                 providers, theme, router

each feature:
  domain/        entities, repository interface, use cases (plain Dart)
  data/          models, remote and local data sources, repository implementation
  presentation/  bloc or cubit, pages, widgets
```

## Design decisions

- **Every event gets the concurrency rule that fits it.** `ProductListBloc` uses `restartable` for loads and searches (a newer request replaces an older one) and `droppable` for paging (scroll fires constantly, only one page request should run). Search waits a short moment, and checks `emit.isDone` so a cancelled keystroke never hits the network.
- **A slow answer cannot overwrite a newer one.** After every `await` the bloc checks that the query and list it started with are still current. Without this, an old page of results can land on top of a new search.
- **Errors are values.** Use cases and repositories return a sealed `Result<T>` (`Ok` or `Err`). Data sources throw typed exceptions, and `guard` turns them into domain failures in one place, with an exhaustive switch so a new exception type cannot be forgotten. Timeouts, offline, server errors and bad credentials each produce a different message.
- **Auth drives navigation.** `AuthCubit` holds the session state and `go_router` re-runs its redirect whenever it changes. The rules live in a plain function, `authRedirect`, so they are unit tested without building a router.
- **Bad data does not crash the app.** A response with a missing field becomes a `ServerException` instead of a raw cast error, and a corrupted value in local storage is discarded instead of throwing at start-up.
- **Rebuild only what changed.** The heart on each product card listens to the favorites cubit with `buildWhen`, so toggling one favorite does not rebuild every card.
- **Business rules in the domain.** Blank credentials are rejected by the `Login` use case, so the rule holds whichever UI calls it.

## Getting started

The platform folders are not stored in the repo. Generate them once:

```bash
flutter create . --platforms=android,ios,web
flutter pub get
flutter run
```

## Tests

Run `flutter test`. About 100 tests, none of which touch the network.

| Layer | What is checked |
| --- | --- |
| Core | `guard` maps every exception, http helpers reject malformed responses |
| Domain | `Login` validation and delegation |
| Data | data sources against a fake `http.Client` and in-memory `shared_preferences`; repositories map errors to failures |
| Bloc and cubit | state sequences with `bloc_test`, including paging, stale searches and failures |
| Widgets | login form, product list states, detail page, favorite button, router redirect |

## Continuous integration

GitHub Actions runs `flutter analyze` (lints are errors), the tests, and a web build on every push. The web build checks that the app compiles for the browser.

## Stack

Flutter, `flutter_bloc` and `bloc_concurrency`, `go_router`, `get_it`, `http`, `shared_preferences`, `equatable`, `mocktail` and `bloc_test`.

## Notes

DummyJSON returns a token at login but does not require it for the catalog, so the app stores the session and does not send the token yet. Sending it would happen in one place, a small wrapper around `http.Client`.
