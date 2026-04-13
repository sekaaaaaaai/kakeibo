<script setup>
import { onMounted, reactive, ref } from "vue"
import { apiFetch } from "../lib/api"

const loading = ref(false)
const errorMessage = ref("")
const groups = ref([])
const editStates = reactive({})
const newGroup = reactive({ name: "" })

function initializeEditStates() {
  Object.keys(editStates).forEach((key) => delete editStates[key])
  groups.value.forEach((group) => {
    editStates[group.id] = { name: group.name }
  })
}

async function loadGroups() {
  loading.value = true
  errorMessage.value = ""

  try {
    groups.value = await apiFetch("/api/v1/groups")
    initializeEditStates()
  } catch (error) {
    errorMessage.value = error.message
  } finally {
    loading.value = false
  }
}

async function createGroup() {
  try {
    await apiFetch("/api/v1/groups", {
      method: "POST",
      body: JSON.stringify({ group: newGroup }),
    })
    newGroup.name = ""
    await loadGroups()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function updateGroup(groupId) {
  try {
    await apiFetch(`/api/v1/groups/${groupId}`, {
      method: "PUT",
      body: JSON.stringify({ group: editStates[groupId] }),
    })
    await loadGroups()
  } catch (error) {
    errorMessage.value = error.message
  }
}

async function deleteGroup(group) {
  const confirmed = window.confirm(`グループ「${group.name}」を削除します。関連ユーザーと取引も削除されます。続行しますか？`)
  if (!confirmed) return

  try {
    await apiFetch(`/api/v1/groups/${group.id}`, { method: "DELETE" })
    await loadGroups()
  } catch (error) {
    errorMessage.value = error.message
  }
}

onMounted(async () => {
  await loadGroups()
})
</script>

<template>
  <v-container class="py-8" max-width="900">
    <h1 class="text-h4 font-weight-bold mb-4">グループ管理</h1>

    <v-progress-linear v-if="loading" indeterminate color="primary" class="mb-4" />
    <v-alert v-if="errorMessage" type="error" variant="tonal" class="mb-4">{{ errorMessage }}</v-alert>

    <v-card rounded="xl" elevation="1" border class="mb-4">
      <v-card-title>グループを追加</v-card-title>
      <v-card-text>
        <v-form @submit.prevent="createGroup">
          <v-row dense>
            <v-col cols="12" md="9">
              <v-text-field v-model="newGroup.name" label="グループ名" required />
            </v-col>
            <v-col cols="12" md="3" class="d-flex align-center">
              <v-btn type="submit" color="primary" block prepend-icon="mdi-plus">追加</v-btn>
            </v-col>
          </v-row>
        </v-form>
      </v-card-text>
    </v-card>

    <v-card rounded="xl" elevation="1" border>
      <v-card-title>グループ一覧</v-card-title>
      <v-card-text class="pa-0">
        <v-table density="comfortable">
          <thead>
            <tr>
              <th>名前</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="group in groups" :key="group.id">
              <td>
                <v-text-field v-model="editStates[group.id].name" hide-details density="compact" />
              </td>
              <td style="width: 170px">
                <v-btn size="small" variant="tonal" color="primary" class="mr-2" @click="updateGroup(group.id)">保存</v-btn>
                <v-btn size="small" variant="text" color="error" @click="deleteGroup(group)">削除</v-btn>
              </td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </v-container>
</template>
