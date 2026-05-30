# Project Folder Structure & Conventions

This document describes the folder structure, naming conventions, and architectural patterns used in this Next.js project. Use it as a reference when scaffolding new features in another project that should follow the same structure.

## Tech Stack (for context)

- **Framework:** Next.js 16 (App Router) with TypeScript
- **i18n:** `next-intl` with `[locale]` segment
- **State / Data:** Redux Toolkit (global state), TanStack React Query (server state)
- **Forms:** React Hook Form + Zod
- **Styling / UI:** Tailwind CSS 4 + shadcn/ui (Radix primitives) + `lucide-react` / `react-icons`
- **HTTP:** Axios (single `apiClient` instance)
- **Theming:** `next-themes`
- **Notifications:** `react-toastify`

---

## Top-Level Layout

```
src/
├── app/                # Next.js App Router (routes only — thin pages)
├── assets/             # Static fonts, images
├── core/               # App-wide infrastructure (network, providers, store, i18n, utils)
├── features/           # Domain features (the bulk of the code)
├── shared/             # Reusable, cross-feature UI & hooks
├── globals.css
├── page.tsx
└── proxy.ts            # next-intl proxy
```

---

## `src/app/` — Routes

The App Router contains **only thin pages** that import a `*PageBody` component from the matching feature folder. No business logic, no fetching here.

```
src/app/
└── [locale]/
    ├── layout.tsx                  # Root layout: providers, fonts, sidebar wrapper
    ├── page.tsx
    ├── login/
    │   └── page.tsx
    ├── users/
    │   ├── log/
    │   │   └── page.tsx            # → renders <UsersLogPageBody />
    │   └── create/
    │       └── [[...id]]/          # optional catch-all → create + edit/view modes
    │           └── page.tsx
    ├── ads/
    │   ├── log/
    │   ├── details/
    │   └── seller/
    ├── categories/
    ├── field-definitions/
    ├── complaints/
    ├── poster-ads/
    └── profile/
```

### Page file pattern

```tsx
// src/app/[locale]/users/log/page.tsx
import UsersLogPageBody from "@/src/features/users/log/components/usersLogPageBody";

export default function UsersManagementLog() {
  return <UsersLogPageBody />;
}
```

### Route naming rules

- Each domain has a route segment (e.g. `users/`, `ads/`).
- Within a domain, sub-routes mirror the feature sub-folders (commonly `log/`, `create/`, `details/`).
- For create+edit+view on a single screen, use a Next.js optional catch-all: `create/[[...id]]/page.tsx`. The `id` is decoded inside the feature hook (see `useCreateUser` pattern).

---

## `src/core/` — App Infrastructure

Reusable, domain-agnostic plumbing. **Nothing here should know about a specific feature.**

```
src/core/
├── config/
│   └── navigation.tsx           # Sidebar / main navigation config
├── i18n/
│   ├── navigation.ts            # next-intl Link/redirect helpers
│   ├── request.ts
│   └── routing.ts               # locales, defaultLocale
├── network/
│   ├── apiClient / axios.ts     # singleton Axios instance + interceptors
│   ├── ApiEndPoints.ts          # central endpoint constants
│   ├── constants.ts
│   └── extractApiErrorMessage.ts
├── providers/
│   ├── ReactQueryProvider.tsx
│   ├── ReduxProvider.tsx
│   └── ThemeProvider.tsx
├── redux/
│   └── CodeTableSlice.ts        # Global slices (cross-feature)
├── services/
│   ├── code-table-api-service.ts
│   ├── cookies/
│   │   ├── cookies_helper.ts    # client-side
│   │   ├── server_cookies.ts    # server-side
│   │   └── cookies_keys.ts
│   └── localStorage/
│       └── localeStorageKeys.ts
├── store.ts                     # Redux store
├── types/
│   ├── InputModeType.ts
│   ├── generalTypes.ts          # DynamicForm, etc.
│   ├── modulesApi.ts
│   ├── enums/                   # *Enum.ts files
│   └── interfaces/              # PascalCase interface files (ApiResponse, MetaInterface, ...)
└── utils/
    ├── constants.ts
    ├── hooks.ts                 # typed redux hooks
    ├── utils.ts                 # cn(), etc.
    └── functions/               # one file per helper (camelCase)
        ├── formatFileSize.ts
        ├── helperAuth.ts
        ├── helperClient.ts
        ├── helperServer.ts
        ├── queryEncodeAndDecode.ts
        ├── urlIdEncoderHelper.ts
        └── ...
```

### Conventions

- **Network:** single `apiClient` (Axios) + a central `ApiEndPoints` object. Feature services consume both.
- **API response shape:** always wrap in `ApiResponse<T>` (success flag, message, data).
- **Types:** `interfaces/` holds `*Interface.ts` files; `enums/` holds `*Enum.ts` files.
- **Utils:** one helper per file in `utils/functions/`, named after the exported function.

---

## `src/shared/` — Cross-Feature UI

Reusable building blocks used by more than one feature. Anything used by exactly one feature stays in that feature's folder.

```
src/shared/
├── components/
│   ├── ui/                      # shadcn primitives (avatar, sheet, sidebar, ...)
│   ├── fields/                  # Form fields wired to react-hook-form
│   │   ├── InputField.tsx
│   │   ├── SelectRequierd.tsx
│   │   ├── MultiSelect.tsx
│   │   ├── DatePickerField.tsx
│   │   ├── AutoComplete.tsx
│   │   └── ...
│   ├── dialogs/
│   │   ├── CustomDialog.tsx
│   │   └── CustomAlertDialog.tsx
│   ├── attachments/             # File upload widgets
│   ├── base-page.tsx            # Layout shell with title/header
│   ├── base-table.tsx           # TanStack Table wrapper
│   ├── BaseContainer.tsx
│   ├── CustomPagination.tsx
│   ├── CustomToolTip.tsx
│   ├── TruncatedCellWithToolTip.tsx
│   ├── customActionsMenu.tsx
│   ├── customErrorComponent.tsx
│   ├── customLottiePlayer.tsx
│   ├── app-sidebar.tsx
│   ├── sidebar-layout-wrapper.tsx
│   ├── sidebar-logo.tsx
│   ├── nav-user.tsx
│   ├── search-form.tsx
│   ├── themeSwitcher.tsx
│   └── version-switcher.tsx
├── hooks/
│   ├── use-mobile.ts
│   ├── useDebounce.tsx
│   └── useIsActive.tsx
├── messages/                    # next-intl translation JSON (en, ar, ...)
└── styles/
    ├── FormAnimation.css
    ├── datepicker.css
    ├── scrollbar.css
    └── toast.css
```

---

## `src/features/` — Domain Features (Most Important)

Every business domain lives under `features/<domain>/`. Inside each domain, code is split by **screen / use-case** (typically `log`, `create`, `details`, `seller`, …) plus an optional `shared/` folder for things used by more than one screen of the same domain.

```
src/features/
├── auth/
├── users/
├── categories/
├── field-definitions/
├── ads/
├── complaints/
└── posterAds/
```

### Per-domain layout

```
src/features/<domain>/
├── <screen-A>/                  # e.g. log
│   ├── components/
│   ├── config/
│   ├── hooks/
│   │   └── api/                 # React Query hooks
│   ├── services/
│   └── types/
│       ├── enums/
│       └── interface/           # NOTE: "interface" (singular) is used in places
├── <screen-B>/                  # e.g. create
│   └── ... same five subfolders
└── shared/                      # types/enums/components reused across screens
    ├── components/
    ├── enums/
    ├── hooks/
    │   └── api/
    ├── services/
    └── types/
        └── interface/
```

### Concrete example — `features/users/`

```
features/users/
├── log/
│   ├── components/
│   │   ├── usersLogPageBody.tsx          # Top-level body rendered by app route
│   │   ├── usersLogHeader.tsx
│   │   ├── usersLogTable.tsx
│   │   ├── UsersSpecialCardsSection.tsx
│   │   └── UsersSpecialCardInfo.tsx
│   ├── config/
│   │   └── getAllUsersFilterConfig.ts    # Zod schema + filter field config
│   ├── hooks/
│   │   ├── useGetAllUsersForm.ts         # form-state hook
│   │   └── api/
│   │       ├── useGetAllUser.ts          # React Query: list
│   │       ├── useDeleteUser.ts          # React Query: mutation
│   │       └── useVerifyUser.ts
│   ├── services/
│   │   └── usersLogApiService.ts         # Axios calls, returns ApiResponse<T>
│   └── types/
│       └── interface/
│           └── UserInterface.ts
├── create/
│   ├── components/
│   │   ├── CreateUserPageBody.tsx
│   │   ├── CreateUserHeaderSection.tsx
│   │   ├── CreateUserFormSection.tsx
│   │   ├── CreateUserRolesSection.tsx
│   │   └── UserVerificationDocumentsSection.tsx
│   ├── config/
│   │   └── createUserConfig.ts           # DynamicForm<T> + Zod schema, exports FormType
│   ├── hooks/
│   │   ├── useCreateUser.ts              # screen orchestration (modes: create/edit/view)
│   │   ├── useCreateUserForm.ts          # react-hook-form setup
│   │   └── api/
│   │       ├── useCreateUserMutation.ts
│   │       ├── useGetUserDetails.ts
│   │       └── useGetUserVerificationDocuments.ts
│   ├── services/
│   │   ├── UserCrudService.ts            # create/update/get
│   │   └── VerificationService.ts
│   └── types/
│       └── interfaces/
│           ├── UserDetailsInterface.ts
│           └── VerficationItemInterface.ts
└── shared/
    └── enums/
        └── getAllUsersFiltersEnums.ts
```

### What goes in each sub-folder

| Folder        | Purpose                                                                          | File naming                                              |
| ------------- | -------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `components/` | React components for this screen only. One top-level `<Feature>PageBody.tsx`.    | PascalCase (occasional camelCase exists — prefer Pascal) |
| `config/`     | Form configs (`DynamicForm<T>`), filter configs, Zod schemas. Export `FormType`. | `camelCaseConfig.ts`                                     |
| `hooks/`      | Non-API hooks: form setup, screen orchestration, derived state.                  | `useXxx.ts`                                              |
| `hooks/api/`  | React Query `useQuery` / `useMutation` wrappers around a service.                | `useGetXxx.ts`, `useXxxMutation.ts`, `useDeleteXxx.ts`   |
| `services/`   | Plain Axios functions grouped as a `const Service = { ... }` object.             | `XxxCrudService.ts` or `xxxLogApiService.ts`             |
| `types/`      | TS interfaces & enums for this screen.                                           | `XxxInterface.ts`, `XxxEnum.ts`                          |

---

## Standard Patterns

### 1. Service (Axios layer)

```ts
// features/<domain>/<screen>/services/XxxCrudService.ts
import { ApiEndPoints } from "@/src/core/network/ApiEndPoints";
import { apiClient } from "@/src/core/network/axios";
import { ApiResponse } from "@/src/core/types/interfaces/ApiResponse";

export const XxxCrudService = {
  async createXxx(payload: XxxFormType): Promise<ApiResponse<{ id: number }>> {
    const { data } = await apiClient.post<ApiResponse<{ id: number }>>(
      ApiEndPoints.createXxx,
      payload,
    );
    return data;
  },
  // updateXxx, getXxx, ...
};
```

### 2. React Query hook (`hooks/api/`)

```ts
// useGetAllXxx.ts
import { useQuery } from "@tanstack/react-query";

export function useGetAllXxx(props: GetAllXxxProps) {
  const { data, isPending, isFetching, refetch, isError, error } = useQuery({
    queryKey: ["getAllXxx", props],
    queryFn: () => XxxLogApiService.getAllXxx(props),
  });
  return {
    data: data?.data,
    isLoading: isPending || isFetching,
    errorMessage: !data?.succeeded ? data?.message : isError ? error.message : undefined,
    refetch,
  };
}
```

```ts
// useCreateXxxMutation.ts
import { useMutation } from "@tanstack/react-query";
import { toast } from "react-toastify";

export const useCreateXxxMutation = () => {
  const router = useRouter();
  return useMutation({
    mutationKey: ["createXxx"],
    mutationFn: ({ id, payload }: { id?: number; payload: XxxFormType }) =>
      id ? XxxCrudService.updateXxx(id, payload) : XxxCrudService.createXxx(payload),
    onSuccess: (data) => {
      if (data.succeeded) {
        toast.success(data.message);
        // router.replace(...)
      } else {
        toast.error(data.message);
      }
    },
    onError: (error) => toast.error(error.message),
  });
};
```

### 3. Form config (`config/`)

A config file exports both the Zod schema-derived `FormType` and a `Get<Feature>Form()` function that returns a `DynamicForm<FormType>` describing fields, labels, icons, placeholders. Translations come from `useTranslations()` (next-intl).

### 4. Screen orchestration hook

```ts
// useCreateXxx.ts — decides create/edit/view mode from URL
export const useCreateXxx = () => {
  const params = useParams();
  const id = extractAndDecodeId(params.id as string[]);
  const [editMode, setEditMode] = useState(false);
  const isEditMode = editMode && id;
  const isViewMode = id && !editMode;
  const isCreateMode = !id;
  return { id, editMode, setEditMode, isCreateMode, isEditMode, isViewMode };
};
```

### 5. Page body component

`<Feature>PageBody.tsx` is the single component imported by the matching `app/.../page.tsx`. It composes header, form sections, tables, etc.

### 6. URL IDs are encoded

IDs in URLs are obfuscated via `encodeId` / `extractAndDecodeId` from `core/utils/functions/urlIdEncoderHelper.ts` (uses Hashids). Always encode when pushing to a URL and decode when reading from params.

---

## Naming Conventions Summary

| Thing                       | Convention                            | Example                                |
| --------------------------- | ------------------------------------- | -------------------------------------- |
| Folder names                | kebab-case                            | `field-definitions/`, `poster-ads/`    |
| Domain folder               | plural noun                           | `users/`, `categories/`, `ads/`        |
| Screen folder               | short verb/noun                       | `log`, `create`, `details`, `seller`   |
| Component file              | PascalCase                            | `CreateUserPageBody.tsx`               |
| Hook file                   | `useXxx.ts` / `useXxx.tsx`            | `useCreateUserForm.ts`                 |
| Service file                | `XxxCrudService.ts` / `xxxApiService` | `UserCrudService.ts`                   |
| Interface file              | `XxxInterface.ts`                     | `UserInterface.ts`                     |
| Enum file                   | `xxxEnums.ts`                         | `getAllUsersFiltersEnums.ts`           |
| Config file                 | `xxxConfig.ts`                        | `createUserConfig.ts`                  |
| Form type (exported)        | `XxxFormType`                         | `CreateUserFormType`                   |
| React Query key             | array starting with action name       | `["getAllUsers", props]`               |
| API endpoint constant       | property on `ApiEndPoints`            | `ApiEndPoints.createUser`              |

---

## Recipe: Adding a New Domain Feature

To add a new domain `xxx` with a log page and a create page:

1. **Routes** — create thin pages:
   - `src/app/[locale]/xxx/log/page.tsx` → renders `<XxxLogPageBody />`
   - `src/app/[locale]/xxx/create/[[...id]]/page.tsx` → renders `<CreateXxxPageBody />`

2. **Endpoints** — add new keys to `src/core/network/ApiEndPoints.ts`.

3. **Feature folder** — create:
   ```
   src/features/xxx/
   ├── shared/types/interface/XxxInterface.ts
   ├── log/
   │   ├── services/xxxLogApiService.ts
   │   ├── hooks/api/useGetAllXxx.ts
   │   ├── hooks/api/useDeleteXxx.ts
   │   ├── hooks/useGetAllXxxForm.ts
   │   ├── config/getAllXxxFilterConfig.ts
   │   ├── components/xxxLogPageBody.tsx
   │   ├── components/xxxLogHeader.tsx
   │   └── components/xxxLogTable.tsx
   └── create/
       ├── services/XxxCrudService.ts
       ├── hooks/api/useCreateXxxMutation.ts
       ├── hooks/api/useGetXxxDetails.ts
       ├── hooks/useCreateXxx.ts
       ├── hooks/useCreateXxxForm.ts
       ├── config/createXxxConfig.ts
       ├── components/CreateXxxPageBody.tsx
       ├── components/CreateXxxHeaderSection.tsx
       └── components/CreateXxxFormSection.tsx
   ```

4. **Navigation** — add the entry to `src/core/config/navigation.tsx`.

5. **Translations** — add keys to `src/shared/messages/<locale>.json`.

---

## Hard Rules

- **No business logic in `app/` pages.** They import and render a single `*PageBody` component.
- **No direct `fetch` / `axios` calls in components.** Always go through a `services/` file, called by a `hooks/api/` hook.
- **No feature-specific code in `core/` or `shared/`.** If only one feature uses it, it belongs in that feature.
- **Every API response is `ApiResponse<T>`.** Hooks unwrap `data.data` and surface `errorMessage` from `data.message`.
- **Forms** use react-hook-form + Zod, configured through a `DynamicForm<T>` in `config/`.
- **i18n everywhere** — strings come from `useTranslations()`, never hard-coded.
- **Encode IDs in URLs** with the Hashids helpers; never put raw numeric IDs in routes.
