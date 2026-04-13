<template>
  <v-app>
    <v-app-bar color="primary" density="comfortable">
      <v-app-bar-title class="font-weight-bold">家計簿</v-app-bar-title>
      <v-btn to="/transactions" variant="text">取引</v-btn>
      <v-btn to="/categories" variant="text">カテゴリ</v-btn>
      <v-btn to="/budgets" variant="text">月次予算</v-btn>
      <v-btn to="/users" variant="text">ユーザー管理</v-btn>
      <v-btn to="/groups" variant="text">グループ管理</v-btn>
    </v-app-bar>

    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>
