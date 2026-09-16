import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["contract", "amount", "remainingBox", "remainingText"]
  static values  = { contracts: Object }

  connect() {
    this.update()
  }

  update() {
    const contractId = this.contractTarget.value
    if (!contractId) {
      this.remainingBoxTarget.style.display = "none"
      return
    }

    const info = this.contractsValue[contractId] || { total: 0, paid: 0, currency: "SYP" }
    const remaining = info.total - info.paid

    this.remainingBoxTarget.style.display = "block"
    this.remainingTextTarget.textContent =
      remaining.toLocaleString("ar-SY") + " " + info.currency

    // Prefill amount with remaining if empty
    if (!this.amountTarget.value || this.amountTarget.value === "0") {
      this.amountTarget.value = remaining > 0 ? remaining : ""
    }
  }
}
