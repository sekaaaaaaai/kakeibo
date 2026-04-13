<script setup>
import { computed, onMounted, reactive, ref } from "vue"
import { apiFetch } from "../lib/api"

const loading = ref(false)
const errorMessage = ref("")
const users = ref([])
const groups = ref([])
const editStates = reactive({})

const newUser = reactive({ name: "", group_id: null })

const groupItems = computed(() =>
  groups.value.map((group) => ({ title: group.name, value: group.id })),
)

function initializeEditStates() {
  Object.keys(editStates).forEach((key) => delete editStates[key])
  users.value.forEach((user) => {
    editStates[user.id] = { name: user.name, group_id: user.group_id }
  })
}

async function loadData() {
  loading.value = true
  errorMessage.value = ""

  try {
    const [usersRes, groupsRes] = await Promise.all([
      apiFetch("/api/v1/users"),
      apiFetch("/api/v1/groups"),
    ])

    users.value = usersRes
    groups.value = groupsRes
    initializeEditStates()

    if (!newUser.group_id && groupsRes[0]) {
      newUser.group_id = groupsRes[0].id
    }
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

async function createUser() {
  try {
    await apiFetch("/api/v1/users", {
      method: "POST",
      body: JSON.stringify({
        user: {
          name: newUser.name,
          group_id: Number(newUser.group_id),
        },
      }),
    })

    newUser.name = ""
    await loadData()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function updateUser(userId) {
  try {
    const payload = editStates[userId]
    await apiFetch(`/api/v1/users/${userId}`, {
      method: "PUT",
      body: JSON.stringify({
        user: {
          name: payload.name,
          group_id: Number(payload.group_id),
        },
      }),
    })

    await loadData()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function deleteUser(user) {
  const confirmed = window.confirm(`ユーザー「${user.name}」を削除します。関連取引も削除されます。続行しますか？`)
  if (!confirmed) return

  try {
    await apiFetch(`/api/v1/users/${user.id}`, { method: "DELETE" })
    await loadData()
  } catch (error) {
    errorMessage.value = error.message
  }
}

onMounted(async () => {
  await loadData()
})
</script>

<template>
  <v-container class="py-8" max-width="1000">
    <h1 class="text-h4 font-weight-bold mb-4">ユーザー管理</h1>

    <v-progress-linear v-if="loading" indeterminate color="primary" class="mb-4" />
    <v-alert v-if="errorMessage" type="error" variant="tonal" class="mb-4">{{ errorMessage }}</v-alert>

    <v-card rounded="xl" elevation="1" border class="mb-4">
      <v-card-title>ユーザーを追加</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="createUser">
          <v-row dense>
            <v-col cols="12" md="5">
              <v-text-field v-model="newUser.name" label="ユーザー名" required />
            </v-col>
            <v-col cols="12" md="5">
              <v-select v-model="newUser.group_id" :items="groupItems" label="グループ" item-title="title" item-value="value" required />
            </v-col>
            <v-col cols="12" md="2" class="d-flex align-center">
              <v-btn type="submit" color="primary" block prepend-icon="mdi-account-plus">追加</v-btn>
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>
    </v-card>

    <v-card rounded="xl" elevation="1" border>
      <v-card-title>ユーザー一覧</v-card-title>
      <v-card-text class="pa-0">
        <v-table density="comfortable">
          <thead>
            <tr>
              <th>名前</th>
              <th>グループ</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in users" :key="user.id">
              <td>
                <v-text-field v-model="editStates[user.id].name" hide-details density="compact" />
              </td>
              <td style="width: 260px">
                <v-select
                  v-model="editStates[user.id].group_id"
                  :items="groupItems"
                  item-title="title"
                  item-value="value"
                  hide-details
                  density="compact"
                />
              </td>
              <td style="width: 170px">
                <v-btn size="small" variant="tonal" color="primary" class="mr-2" @click="updateUser(user.id)">保存</v-btn>
                <v-btn size="small" variant="text" color="error" @click="deleteUser(user)">削除</v-btn>
              </td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </v-container>
</template>
