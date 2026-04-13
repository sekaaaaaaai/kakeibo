<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue"
import { apiFetch } from "../lib/api"

const today = new Date().toISOString().slice(0, 10)
const thisMonth = new Date().toISOString().slice(0, 7)

const loading = ref(false)
const errorMessage = ref("")

const month = ref(thisMonth)
const selectedUserId = ref(null)

const report = ref({ income: 0, expense: 0, balance: 0, by_scope: [], by_category: [] })
const categories = ref([])
const users = ref([])
const transactions = ref([])
const budgets = ref([])

const newTransaction = reactive({ category_id: null, aggregation_scope: "shared", amount: "", occurred_on: today, memo: "" })

const categoryItems = computed(() =>
  categories.value.map((category) => ({
    title: `${category.kind === "income" ? "収入" : "支出"}: ${category.name}`,
    value: category.id,
  })),
)

const aggregationScopeItems = [
  { title: "共同", value: "shared" },
  { title: "個人", value: "personal" },
]

const filterUserItems = computed(() =>
  users.value.map((user) => ({ title: `${user.group_name} / ${user.name}`, value: user.id })),
)

const monthLabel = computed(() => `${month.value} 月`)
const scopeRows = computed(() =>
  (report.value.by_scope || []).map((item) => ({
    label: item.scope === "personal" ? "個人" : "共同",
    income: Number(item.income || 0),
    expense: Number(item.expense || 0),
    balance: Number(item.balance || 0),
  })),
)

function monthQuery() {
  const query = new URLSearchParams({ month: month.value })
  if (selectedUserId.value) {
    query.set("user_id", String(selectedUserId.value))
  }
  return `?${query.toString()}`
}

async function loadMasterData() {
  const [categoriesRes, usersRes] = await Promise.all([
    apiFetch("/api/v1/categories"),
    apiFetch("/api/v1/users"),
  ])

  categories.value = categoriesRes
  users.value = usersRes

  if (!selectedUserId.value && usersRes[0]) {
    selectedUserId.value = usersRes[0].id
  }
  if (!newTransaction.category_id && categoriesRes[0]) {
    newTransaction.category_id = categoriesRes[0].id
  }
}

async function loadMonthData() {
  const query = monthQuery()
  const [txRes, reportRes, budgetRes] = await Promise.all([
    apiFetch(`/api/v1/transactions${query}`),
    apiFetch(`/api/v1/reports/monthly${query}`),
    apiFetch(`/api/v1/monthly_budgets?month=${month.value}`),
  ])

  transactions.value = txRes
  report.value = reportRes
  budgets.value = budgetRes
}

async function initialize() {
  loading.value = true
  errorMessage.value = ""

  try {
    await loadMasterData()
    await loadMonthData()
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

watch([month, selectedUserId], async () => {
  try {
    await loadMonthData()
  } catch (error) {
    errorMessage.value = error.message
  }
})

onMounted(async () => {
  await initialize()
})

async function createTransaction() {
  if (!selectedUserId.value) {
    errorMessage.value = "表示ユーザーを選択してください。"
    return
  }

  try {
    await apiFetch("/api/v1/transactions", {
      method: "POST",
      body: JSON.stringify({
        transaction: {
          ...newTransaction,
          user_id: Number(selectedUserId.value),
          category_id: Number(newTransaction.category_id),
          amount: Number(newTransaction.amount),
        },
      }),
    })

    newTransaction.amount = ""
    newTransaction.memo = ""

    await loadMonthData()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function deleteTransaction(id) {
  try {
    await apiFetch(`/api/v1/transactions/${id}`, { method: "DELETE" })
    await loadMonthData()
  } catch (error) {
    errorMessage.value = error.message
  }
}
</script>

<template>
  <v-container class="py-8" max-width="1200">
    <div class="d-flex align-center justify-space-between mb-4 ga-4 flex-wrap">
      <h1 class="text-h4 font-weight-bold">取引</h1>
      <div class="d-flex ga-3 flex-wrap">
        <v-text-field v-model="month" type="month" label="対象月" density="comfortable" hide-details style="max-width: 220px" />
        <v-select v-model="selectedUserId" :items="filterUserItems" label="表示ユーザー" density="comfortable" hide-details style="min-width: 240px" />
      </div>
    </div>

    <v-progress-linear v-if="loading" indeterminate color="primary" class="mb-4" />
    <v-alert v-if="errorMessage" type="error" variant="tonal" class="mb-4">{{ errorMessage }}</v-alert>

    <v-row class="mb-2" dense>
      <v-col cols="12" md="4">
        <v-card rounded="xl" elevation="1" border>
          <v-card-title class="text-subtitle-1">{{ monthLabel }} 収入</v-card-title>
          <v-card-text class="text-h5 text-success">¥{{ Number(report.income || 0).toLocaleString() }}</v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card rounded="xl" elevation="1" border>
          <v-card-title class="text-subtitle-1">{{ monthLabel }} 支出</v-card-title>
          <v-card-text class="text-h5 text-error">¥{{ Number(report.expense || 0).toLocaleString() }}</v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card rounded="xl" elevation="1" border>
          <v-card-title class="text-subtitle-1">{{ monthLabel }} 収支</v-card-title>
          <v-card-text class="text-h5" :class="Number(report.balance || 0) >= 0 ? 'text-success' : 'text-error'">
            ¥{{ Number(report.balance || 0).toLocaleString() }}
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card rounded="xl" elevation="1" border class="mb-4">
      <v-card-title>集計区分別サマリー（個人 / 共同）</v-card-title>
      <v-card-text class="pa-0">
        <v-table density="comfortable">
          <thead>
            <tr>
              <th>集計区分</th>
              <th class="text-right">収入</th>
              <th class="text-right">支出</th>
              <th class="text-right">収支</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in scopeRows" :key="row.label">
              <td>{{ row.label }}</td>
              <td class="text-right text-success">¥{{ row.income.toLocaleString() }}</td>
              <td class="text-right text-error">¥{{ row.expense.toLocaleString() }}</td>
              <td class="text-right" :class="row.balance >= 0 ? 'text-success' : 'text-error'">
                ¥{{ row.balance.toLocaleString() }}
              </td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>

    <v-row dense>
      <v-col cols="12">
        <v-card rounded="xl" elevation="1" border class="mb-4">
          <v-card-title>取引を登録</v-card-title>
          <v-card-text>
            <v-form @submit.prevent="createTransaction">
              <v-row dense>
                <v-col cols="12" sm="6" md="3">
                  <v-text-field v-model="newTransaction.occurred_on" type="date" label="日付" required />
                </v-col>
                <v-col cols="12" sm="6" md="3">
                  <v-select v-model="newTransaction.category_id" :items="categoryItems" label="カテゴリ" item-title="title" item-value="value" required />
                </v-col>
                <v-col cols="12" sm="6" md="3">
                  <v-text-field v-model="newTransaction.amount" type="number" min="1" label="金額" required />
                </v-col>
                <v-col cols="12" sm="6" md="3">
                  <v-select
                    v-model="newTransaction.aggregation_scope"
                    :items="aggregationScopeItems"
                    label="集計区分"
                    item-title="title"
                    item-value="value"
                    required
                  />
                </v-col>
                <v-col cols="12" md="12">
                  <v-text-field v-model="newTransaction.memo" label="メモ" />
                </v-col>
              </v-row>
              <v-btn type="submit" color="primary" prepend-icon="mdi-check">登録</v-btn>
            </v-form>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-row dense>
      <v-col cols="12" lg="8">
        <v-card rounded="xl" elevation="1" border class="mb-4">
          <v-card-title>取引一覧</v-card-title>
          <v-card-text class="pa-0">
            <v-table density="comfortable">
              <thead>
                <tr>
                  <th>日付</th>
                  <th>ユーザー</th>
                  <th>カテゴリ</th>
                  <th>集計区分</th>
                  <th>金額</th>
                  <th>メモ</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="tx in transactions" :key="tx.id">
                  <td>{{ tx.occurred_on }}</td>
                  <td>{{ tx.user_name }}</td>
                  <td>{{ tx.category_kind === "income" ? "収入" : "支出" }}: {{ tx.category_name }}</td>
                  <td>{{ tx.aggregation_scope === "personal" ? "個人" : "共同" }}</td>
                  <td :class="tx.category_kind === 'income' ? 'text-success' : 'text-error'">¥{{ Number(tx.amount).toLocaleString() }}</td>
                  <td>{{ tx.memo }}</td>
                  <td>
                    <v-btn color="error" variant="text" size="small" icon="mdi-delete" @click="deleteTransaction(tx.id)" />
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" lg="4">
        <v-card rounded="xl" elevation="1" border class="mb-4">
          <v-card-title>カテゴリ別合計</v-card-title>
          <v-list density="comfortable">
            <v-list-item
              v-for="row in report.by_category"
              :key="`${row.kind}-${row.category_id}`"
              :title="`${row.kind === 'income' ? '収入' : '支出'} / ${row.category_name}`"
            >
              <template #append>
                <v-chip :color="row.kind === 'income' ? 'success' : 'error'" variant="tonal">
                  ¥{{ Number(row.total).toLocaleString() }}
                </v-chip>
              </template>
            </v-list-item>
          </v-list>
        </v-card>

        <v-card v-if="budgets.length" rounded="xl" elevation="1" border>
          <v-card-title>月次予算</v-card-title>
          <v-list density="comfortable">
            <v-list-item v-for="budget in budgets" :key="budget.id" :title="budget.category_name">
              <template #append>
                <v-chip color="secondary" variant="tonal">¥{{ Number(budget.amount).toLocaleString() }}</v-chip>
              </template>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
