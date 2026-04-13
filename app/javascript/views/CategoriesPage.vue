<script setup>
import { computed, onMounted, reactive, ref } from "vue"
import { apiFetch } from "../lib/api"

const loading = ref(false)
const errorMessage = ref("")
const categories = ref([])

const newCategory = reactive({ name: "", kind: "expense", color: "#64748b", sort_order: 0 })
const editStates = reactive({})

const kindItems = [
  { title: "支出", value: "expense" },
  { title: "収入", value: "income" },
]

const expenseCategories = computed(() => categories.value.filter((c) => c.kind === "expense"))
const incomeCategories = computed(() => categories.value.filter((c) => c.kind === "income"))

function initializeEditStates() {
  Object.keys(editStates).forEach((key) => {
    delete editStates[key]
  })

  categories.value.forEach((category) => {
    editStates[category.id] = {
      name: category.name,
      kind: category.kind,
      color: category.color,
      sort_order: category.sort_order,
    }
  })
}

async function loadCategories() {
  loading.value = true
  errorMessage.value = ""

  try {
    categories.value = await apiFetch("/api/v1/categories")
    initializeEditStates()
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

async function createCategory() {
  try {
    await apiFetch("/api/v1/categories", {
      method: "POST",
      body: JSON.stringify({ category: newCategory }),
    })

    newCategory.name = ""
    newCategory.kind = "expense"
    newCategory.color = "#64748b"
    newCategory.sort_order = 0

    await loadCategories()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function updateCategory(categoryId) {
  try {
    const payload = editStates[categoryId]

    await apiFetch(`/api/v1/categories/${categoryId}`, {
      method: "PUT",
      body: JSON.stringify({ category: payload }),
    })

    await loadCategories()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function deleteCategory(categoryId, categoryName) {
  const confirmed = window.confirm(`カテゴリ「${categoryName}」を削除します。関連する取引と予算も削除されます。続行しますか？`)
  if (!confirmed) return

  try {
    await apiFetch(`/api/v1/categories/${categoryId}`, { method: "DELETE" })
    await loadCategories()
  } catch (error) {
    errorMessage.value = error.message
  }
}

onMounted(async () => {
  await loadCategories()
})
</script>

<template>
  <v-container class="py-8" max-width="1000">
    <h1 class="text-h4 font-weight-bold mb-4">カテゴリ</h1>

    <v-progress-linear v-if="loading" indeterminate color="primary" class="mb-4" />
    <v-alert v-if="errorMessage" type="error" variant="tonal" class="mb-4">{{ errorMessage }}</v-alert>

    <v-card rounded="xl" elevation="1" border class="mb-4">
      <v-card-title>カテゴリを追加</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="createCategory">
          <v-row dense>
            <v-col cols="12" md="4">
              <v-text-field v-model="newCategory.name" label="カテゴリ名" required />
            </v-col>
            <v-col cols="12" md="3">
              <v-select v-model="newCategory.kind" :items="kindItems" label="種別" item-title="title" item-value="value" />
            </v-col>
            <v-col cols="12" md="2">
              <v-text-field v-model="newCategory.color" type="color" label="色" />
            </v-col>
            <v-col cols="12" md="2">
              <v-text-field v-model.number="newCategory.sort_order" type="number" label="表示順" />
            </v-col>
            <v-col cols="12" md="1" class="d-flex align-center">
              <v-btn type="submit" color="primary" block prepend-icon="mdi-plus">追加</v-btn>
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>
    </v-card>

    <v-row dense>
      <v-col cols="12" md="6">
        <v-card rounded="xl" elevation="1" border>
          <v-card-title>支出カテゴリ（編集・削除）</v-card-title>
          <v-card-text class="pa-0">
            <v-table density="comfortable">
              <thead>
                <tr>
                  <th>色</th>
                  <th>名前</th>
                  <th>並び順</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="category in expenseCategories" :key="category.id">
                  <td style="width: 72px">
                    <v-text-field v-model="editStates[category.id].color" type="color" hide-details density="compact" />
                  </td>
                  <td>
                    <v-text-field v-model="editStates[category.id].name" hide-details density="compact" />
                  </td>
                  <td style="width: 120px">
                    <v-text-field v-model.number="editStates[category.id].sort_order" type="number" hide-details density="compact" />
                  </td>
                  <td style="width: 120px">
                    <v-btn size="small" variant="tonal" color="primary" class="mr-2" @click="updateCategory(category.id)">保存</v-btn>
                    <v-btn size="small" variant="text" color="error" @click="deleteCategory(category.id, category.name)">削除</v-btn>
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="6">
        <v-card rounded="xl" elevation="1" border>
          <v-card-title>収入カテゴリ（編集・削除）</v-card-title>
          <v-card-text class="pa-0">
            <v-table density="comfortable">
              <thead>
                <tr>
                  <th>色</th>
                  <th>名前</th>
                  <th>並び順</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="category in incomeCategories" :key="category.id">
                  <td style="width: 72px">
                    <v-text-field v-model="editStates[category.id].color" type="color" hide-details density="compact" />
                  </td>
                  <td>
                    <v-text-field v-model="editStates[category.id].name" hide-details density="compact" />
                  </td>
                  <td style="width: 120px">
                    <v-text-field v-model.number="editStates[category.id].sort_order" type="number" hide-details density="compact" />
                  </td>
                  <td style="width: 120px">
                    <v-btn size="small" variant="tonal" color="primary" class="mr-2" @click="updateCategory(category.id)">保存</v-btn>
                    <v-btn size="small" variant="text" color="error" @click="deleteCategory(category.id, category.name)">削除</v-btn>
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>
