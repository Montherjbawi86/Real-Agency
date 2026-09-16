import { application } from "./application"
import ContractAutofillController from "./contract_autofill_controller"
import PaymentAutofillController from "./payment_autofill_controller"

application.register("contract-autofill", ContractAutofillController)
application.register("payment-autofill", PaymentAutofillController)
