require "prawn"
require "prawn/table"

class PaymentPdf
  def initialize(payment)
    @payment  = payment
    @party    = payment.party
    @contract = payment.contract
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 50) do |pdf|
      font_path = find_arabic_font
      if font_path
        pdf.font_families.update("Arabic" => { normal: font_path, bold: font_path })
        pdf.font "Arabic"
      end

      pdf.text "إيصال دفع", size: 28, style: :bold, align: :center
      pdf.move_down 10
      pdf.text "رقم الإيصال: ##{@payment.id}", align: :center
      pdf.text "التاريخ: #{(@payment.paid_on || Date.current)}", align: :center
      pdf.move_down 20

      rows = [
        ["اسم الدافع",     @party&.full_name || "—"],
        ["رقم الهاتف",     @party&.phone || "—"],
        ["رقم العقد",      @contract ? "##{@contract.id}" : "—"],
        ["الموضوع",        @contract&.subject&.try(:title) || "—"],
        ["تاريخ الاستحقاق", @payment.due_on.to_s],
        ["طريقة الدفع",    method_ar],
        ["الحالة",         @payment.paid? ? "مدفوعة" : "معلقة"],
      ]

      pdf.table(rows, width: pdf.bounds.width, cell_style: { padding: 8, size: 12 }) do
        columns(0).font_style = :bold
        columns(0).background_color = "EEEEEE"
      end

      pdf.move_down 20
      pdf.text "المبلغ الإجمالي: #{@payment.amount.to_i} #{@payment.currency}",
               size: 18, style: :bold, align: :center

      pdf.move_down 40
      pdf.stroke_horizontal_rule
      pdf.move_down 10
      pdf.text "سوريا للعقارات والسيارات", align: :center, size: 10
      pdf.text "info@syria-agencies.sy | 011 123 4567", align: :center, size: 10
    end.render
  end

  private

  def method_ar
    { cash: "نقداً", bank: "حوالة بنكية", sham_cash: "شام كاش", haram: "هرم", other: "أخرى" }[@payment.payment_method.to_sym]
  end

  def find_arabic_font
    [ Rails.root.join("app/assets/fonts/NotoNaskhArabic-Regular.ttf").to_s,
      "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
      "/Library/Fonts/Arial Unicode.ttf" ].find { |p| File.exist?(p) }
  end
end
