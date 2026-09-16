require "prawn"
require "prawn/table"

class ContractPdf
  def initialize(contract)
    @contract = contract
    @party    = contract.party
    @subject  = contract.subject
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 50) do |pdf|
      font_path = find_arabic_font
      if font_path
        pdf.font_families.update("Arabic" => { normal: font_path, bold: font_path })
        pdf.font "Arabic"
      end

      # Header
      pdf.text "عقد #{@contract.kind_ar}", size: 28, style: :bold, align: :center
      pdf.move_down 10
      pdf.text "رقم العقد: ##{@contract.id}", align: :center
      pdf.text "التاريخ: #{Date.current}", align: :center
      pdf.move_down 20

      # Parties
      pdf.text "الأطراف", size: 16, style: :bold
      pdf.move_down 8
      pdf.table([
        ["الطرف الأول (الوكيل)", @contract.user.display_name],
        ["الطرف الثاني",         @party&.full_name || "—"],
        ["رقم الهاتف",           @party&.phone || "—"],
        ["الرقم الوطني",         @party&.try(:national_id) || "—"]
      ], width: pdf.bounds.width, cell_style: { padding: 8, size: 12 }) do
        columns(0).font_style = :bold
        columns(0).background_color = "EEEEEE"
      end

      pdf.move_down 20

      # Subject
      pdf.text "الموضوع", size: 16, style: :bold
      pdf.move_down 8
      pdf.table([
        ["النوع",       @contract.subject_type_ar],
        ["الوصف",       @subject&.try(:title) || "—"],
        ["العنوان",     @subject&.try(:address) || "—"]
      ], width: pdf.bounds.width, cell_style: { padding: 8, size: 12 }) do
        columns(0).font_style = :bold
        columns(0).background_color = "EEEEEE"
      end

      pdf.move_down 20

      # Terms
      pdf.text "الشروط", size: 16, style: :bold
      pdf.move_down 8
      pdf.table([
        ["نوع العقد",     @contract.kind_ar],
        ["من تاريخ",     @contract.start_date.to_s],
        ["إلى تاريخ",    @contract.end_date.to_s],
        ["المبلغ",       "#{@contract.amount.to_i} #{@contract.currency}"],
        ["الحالة",       @contract.status_ar]
      ], width: pdf.bounds.width, cell_style: { padding: 8, size: 12 }) do
        columns(0).font_style = :bold
        columns(0).background_color = "EEEEEE"
      end

      if @contract.notes.present?
        pdf.move_down 20
        pdf.text "ملاحظات", size: 16, style: :bold
        pdf.move_down 8
        pdf.text @contract.notes, size: 11
      end

      # Signatures
      pdf.move_down 60
      pdf.table([
        ["توقيع الطرف الأول", "توقيع الطرف الثاني"],
        ["_________________", "_________________"]
      ], width: pdf.bounds.width, cell_style: { padding: 12, size: 11, align: :center, borders: [] })

      # Footer
      pdf.move_down 40
      pdf.stroke_horizontal_rule
      pdf.move_down 10
      pdf.text "سوريا للعقارات والسيارات", align: :center, size: 10
      pdf.text "info@syria-agencies.sy | 011 123 4567", align: :center, size: 10
      pdf.text "هذا العقد صادر إلكترونياً من المنصة.", align: :center, size: 9
    end.render
  end

  private

  def find_arabic_font
    [ Rails.root.join("app/assets/fonts/NotoNaskhArabic-Regular.ttf").to_s,
      "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
      "/Library/Fonts/Arial Unicode.ttf" ].find { |p| File.exist?(p) }
  end
end
