import { createRouter, createWebHashHistory } from "vue-router"
import TransactionsPage from "../views/TransactionsPage.vue"
import CategoriesPage from "../views/CategoriesPage.vue"
import BudgetsPage from "../views/BudgetsPage.vue"
import UsersPage from "../views/UsersPage.vue"
import GroupsPage from "../views/GroupsPage.vue"

const routes = [
  { path: "/", redirect: "/transactions" },
  { path: "/transactions", name: "transactions", component: TransactionsPage },
  { path: "/categories", name: "categories", component: CategoriesPage },
  { path: "/budgets", name: "budgets", component: BudgetsPage },
  { path: "/users", name: "users", component: UsersPage },
  { path: "/groups", name: "groups", component: GroupsPage },
]

export const router = createRouter({
  history: createWebHashHistory(),
  routes,
})
