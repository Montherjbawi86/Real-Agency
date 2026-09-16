import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "subject", "kind", "start", "end",
    "rentalBlock", "saleBlock", "odometerBlock",
    "dailyRate", "days", "amount", "saleAmount"
  ]
  static values = { prices: Object }

  connect() {
    this.toggleRental()
    this.calcRental()
    this.fill()
  }

  fill() {
    if (!this.hasSubjectTarget) return
    const id = this.subjectTarget.value
    if (!id) return
    const price = this.pricesValue[id]
    if (price && this.hasSaleAmountTarget && !this.saleAmountTarget.value) {
      this.saleAmountTarget.value = price
    }
    this.toggleRental()
  }

  toggleRental() {
    if (!this.hasKindTarget) return
    const kind = this.kindTarget.value
    const isCarRental = this.isCarAgent() && kind === "rent"

    if (this.hasRentalBlockTarget) {
      this.rentalBlockTarget.style.display = isCarRental ? "block" : "none"
    }
    if (this.hasSaleBlockTarget) {
      this.saleBlockTarget.classList.toggle("hidden", isCarRental)
    }
    if (this.hasOdometerBlockTarget) {
      this.odometerBlockTarget.style.display = this.isCarAgent() ? "grid" : "none"
    }
    if (this.hasSaleAmountTarget) {
      this.saleAmountTarget.required = !isCarRental
    }
    if (this.hasDailyRateTarget) {
      this.dailyRateTarget.required = isCarRental
    }
  }

  calcRental() {
    if (!this.hasStartTarget || !this.hasEndTarget) return
    if (!this.hasDailyRateTarget || !this.hasDaysTarget) return

    const start = this.startTarget.value
    const end   = this.endTarget.value
    if (!start || !end) return

    const startDate = new Date(start)
    const endDate   = new Date(end)
    const diffMs    = endDate - startDate
    const days      = Math.floor(diffMs / (1000 * 60 * 60 * 24)) + 1

    if (days > 0) {
      this.daysTarget.value = days
      const rate  = parseFloat(this.dailyRateTarget.value) || 0
      const total = days * rate
      if (this.hasAmountTarget) {
        this.amountTarget.value = total > 0 ? total : ""
      }
    }
  }

  isCarAgent() {
    return this.hasOdometerBlockTarget
  }
}
