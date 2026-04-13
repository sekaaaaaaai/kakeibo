<script setup>
import { computed, onMounted, reactive, ref, watch } from "vue"
import { apiFetch } from "../lib/api"

const thisMonth = new Date().toISOString().slice(0, 7)

const loading = ref(false)
const errorMessage = ref("")
const month = ref(thisMonth)

const categories = ref([])
const budgets = ref([])
const report = ref({ by_category: [] })

const budgetInputs = reactive({})

const expenseCategories = computed(() => categories.value.filter((c) => c.kind === "expense"))

const spentMap = computed(() => {
  const map = {}
  report.value.by_category
    .filter((item) => item.kind === "expense")
    .forEach((item) => {
      map[item.category_id] = Number(item.total)
    })
  return map
})

const budgetMap = computed(() => {
  const map = {}
  budgets.value.forEach((budget) => {
    map[budget.category_id] = budget
  })
  return map
})

const rows = computed(() =>
  expenseCategories.value.map((category) => {
    const existingBudget = budgetMap.value[category.id]
    const budgetValue = Number(budgetInputs[category.id] ?? existingBudget?.amount ?? 0)
    const spent = Number(spentMap.value[category.id] || 0)

    return {
      category,
      budget: existingBudget,
      budgetValue,
      spent,
      remaining: budgetValue - spent,
    }
  }),
)

async function loadData() {
  loading.value = true
  errorMessage.value = ""

  try {
    const query = `?month=${month.value}`
    const [categoriesRes, budgetsRes, reportRes] = await Promise.all([
      apiFetch("/api/v1/categories"),
      apiFetch(`/api/v1/monthly_budgets${query}`),
      apiFetch(`/api/v1/reports/monthly${query}`),
    ])

    categories.value = categoriesRes
    budgets.value = budgetsRes
    report.value = reportRes

    expenseCategories.value.forEach((category) => {
      const existingBudget = budgetsRes.find((item) => item.category_id === category.id)
      budgetInputs[category.id] = Number(existingBudget?.amount || 0)
    })
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

watch(month, async () => {
  await loadData()
})

onMounted(async () => {
  await loadData()
})

async function saveBudget(categoryId) {
  const amount = Number(budgetInputs[categoryId] || 0)
  const existing = budgetMap.value[categoryId]

  try {
    if (existing) {
      await apiFetch(`/api/v1/monthly_budgets/${existing.id}`, {
        method: "PUT",
        body: JSON.stringify({
          monthly_budget: {
            amount,
            month: `${month.value}-01`,
            category_id: categoryId,
          },
        }),
      })
    } else {
      await apiFetch("/api/v1/monthly_budgets", {
        method: "POST",
        body: JSON.stringify({
          monthly_budget: {
            amount,
            month: `${month.value}-01`,
            category_id: categoryId,
          },
        }),
      })
    }

    await loadData()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function deleteBudget(categoryId) {
  const existing = budgetMap.value[categoryId]
  if (!existing) return

  try {
    await apiFetch(`/api/v1/monthly_budgets/${existing.id}`, { method: "DELETE" })
    budgetInputs[categoryId] = 0
    await loadData()
  } catch (error) {
    errorMessage.value = error.message
  }
}
</script>

<template>
  <v-container class="py-8" max-width="1100">
    <div class="d-flex align-center justify-space-between mb-4 ga-4 flex-wrap">
      <h1 class="text-h4 font-weight-bold">月次予算</h1>
      <v-text-field v-model="month" type="month" label="対象月" density="comfortable" hide-details style="max-width: 220px" />
    </div>

    <v-progress-linear v-if="loading" indeterminate color="primary" class="mb-4" />
    <v-alert v-if="errorMessage" type="error" variant="tonal" class="mb-4">{{ errorMessage }}</v-alert>

    <v-card rounded="xl" elevation="1" border>
      <v-card-title>支出カテゴリごとの予算設定</v-card-title>
      <v-card-text class="pa-0">
        <v-table density="comfortable">
          <thead>
            <tr>
              <th>カテゴリ</th>
              <th class="text-right">予算</th>
              <th class="text-right">実績</th>
              <th class="text-right">残額</th>
              <th class="text-right">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.category.id">
              <td>
                <div class="d-flex align-center ga-2">
                  <v-avatar :color="row.category.color" size="14" rounded="circle" />
                  <span>{{ row.category.name }}</span>
                </div>
              </td>
              <td class="text-right" style="width: 180px">
                <v-text-field
                  v-model.number="budgetInputs[row.category.id]"
                  type="number"
                  min="0"
                  hide-details
                  density="compact"
                  prefix="¥"
                />
              </td>
              <td class="text-right">¥{{ row.spent.toLocaleString() }}</td>
              <td class="text-right" :class="row.remaining >= 0 ? 'text-success' : 'text-error'">
                ¥{{ row.remaining.toLocaleString() }}
              </td>
              <td class="text-right" style="width: 190px">
                <v-btn color="primary" size="small" variant="tonal" class="mr-2" @click="saveBudget(row.category.id)">
                  保存
                </v-btn>
                <v-btn
                  :disabled="!row.budget"
                  color="error"
                  size="small"
                  variant="text"
                  @click="deleteBudget(row.category.id)"
                >
                  削除
                </v-btn>
              </td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </v-container>
</template>
