#!/usr/bin/env ruby

# ODDB::State::PayPal::Ipn -- oddb.org -- 23.12.2011 -- mhatakeyama@ywesee.com
# ODDB::State::PayPal::Ipn -- oddb.org -- 19.04.2005 -- hwyss@ywesee.com

require "util/mail"

module ODDB
  module Util
    module Ipn
      def self.lookandfeel_stub
        session = Plugin::SessionStub.new($oddb)
        session.language = "de"
        session.lookandfeel = LookandfeelBase.new(session)
      end

      def self.process(notification, system)
        id = notification.params["invoice"]
        invoice = system.invoice(id.to_i) or raise "unknown invoice '#{id}'"
        if notification.complete?
          Ipn.process_invoice invoice, system
        else
          invoice.ipn = notification
        end
        invoice.odba_store
        invoice
      end

      def self.process_invoice(invoice, system)
        invoice.payment_received!
        yus_name = invoice.yus_name
        invoice.items.each_value { |item|
          case item.type
          when :poweruser
            system.yus_set_preference(yus_name, "poweruser_duration",
              invoice.max_duration)
            system.yus_grant(yus_name, "login", "org.oddb.PowerUser")
            system.yus_grant(yus_name, "view", "org.oddb", item.expiry_time)
          when :download
            system.yus_grant(yus_name, "download", item.text,
              item.expiry_time)
          end
        }
        invoice.types.each { |type|
          case type
          when :poweruser
            send_poweruser_notification(invoice)
          else
            send_download_notification(invoice)
            send_download_seller_notification(invoice)
          end
        }
      end

      def self.send_download_notification(invoice)
        send_notification(invoice) { |outgoing, recipient, lookandfeel|
          lookandfeel = lookandfeel_stub
          lookandfeel.lookup(:download_mail_subject)
          urls = invoice.items.values.collect { |item|
            data = {
              email: recipient,
              invoice: invoice.oid,
              filename: item.text
            }
            url = lookandfeel._event_url(:download, data)
            protocol = DOWNLOAD_PROTOCOLS.find do |prt|
              %r{#{prt}}.match(item.text)
            end
            if protocol
              parsed = URI.parse url
              parsed.scheme = protocol
              [url, parsed.to_s]
            else
              url
            end
          }.flatten
          salut = lookandfeel.lookup(yus(recipient, :salutation))
          suffix = (urls.size == 1) ? "s" : "p"
          lines = [
            lookandfeel.lookup(:download_mail_body),
            lookandfeel.lookup("download_mail_instr_#{suffix}")
          ]
          parts = [
            lookandfeel.lookup(:download_mail_salut, salut,
              yus(recipient, :name_last)),
            lines.join("\n"),
            urls.join("\n"),
            lookandfeel.lookup(:download_mail_feedback),
            format_invoice(invoice, lookandfeel)
          ]
          parts.join("\n\n")
        }
      end

      def self.send_download_seller_notification(invoice)
        if (name = invoice.yus_name)
          lookandfeel = lookandfeel_stub
          recipient = PAYPAL_RECEIVER
          salut = lookandfeel.lookup(yus(name, :salutation))
          company = yus(name, :company_name)
          business = lookandfeel.lookup(yus(name, :business_area))
          if !company.to_s.strip.empty?
            business = "#{company} (#{business})"
          end
          body = [
            [salut, yus(name, :name_first), yus(name, :name_last)].join(" "),
            business,
            yus(name, :address),
            [yus(name, :plz), yus(name, :city)].join(" "),
            yus(name, :phone),
            yus(name, :email)
          ].compact
          body.push(nil)
          body.push(format_invoice(invoice, lookandfeel))
          recipients = [recipient, "ipn"]
          Util.send_mail(recipients, lookandfeel.lookup(:download_mail_subject), body.join("\n"), ODDB.config.invoice_from)
        end
      rescue => e
        puts e.class
        puts e.message
        puts e.backtrace
      end

      def self.send_poweruser_notification(invoice)
        send_notification(invoice) { |outgoing, recipient, lookandfeel|
          lookandfeel ||= lookandfeel_stub
          lookandfeel.lookup(:poweruser_mail_subject)
          salut = lookandfeel.lookup(yus(recipient, :salutation))
          item = invoice.item_by_text("unlimited access")
          dkey = "poweruser_duration_#{item.duration.to_i}"
          duration = lookandfeel.lookup(dkey)
          [
            lookandfeel.lookup(:poweruser_mail_salut, salut,
              yus(recipient, :name_last)),
            lookandfeel.lookup(:poweruser_mail_body),
            lookandfeel.lookup(:poweruser_mail_instr, duration,
              lookandfeel._event_url(:login_form)),
            lookandfeel.lookup(:poweruser_regulatory)
          ]
        }
      end

      def self.send_notification(invoice, &block)
        if (recipient = invoice.yus_name)
          Util.send_mail([recipient], lookandfeel_stub.lookup(:download_mail_subject), block ? block.call : "", ODDB.config.invoice_from)
        end
      rescue => e
        puts e.class
        puts e.message
        puts e.backtrace
      end

      def self.format_invoice(invoice, lookandfeel)
        lines = [lookandfeel.lookup(:invoice_origin), nil]
        qsizes = []
        tsizes = []
        nsizes = []
        downloads = invoice.items.values.collect { |item|
          qstr = sprintf("%i x", item.quantity)
          qsizes.push(qstr.size)
          tstr = item.text
          tsizes.push(tstr.size)
          nstr = sprintf("%3.2f", item.total_netto)
          nsizes.push(nstr.size)
          [qstr, tstr, nstr]
        }
        tstr = lookandfeel.lookup(:total_netto)
        tsizes.push(tstr.size)
        nstr = sprintf("%3.2f", invoice.total_netto)
        nsizes.push(nstr.size)
        netto_line = [nil, tstr, nstr]
        tstr = lookandfeel.lookup(:vat)
        tsizes.push(tstr.size)
        nstr = sprintf("%3.2f", invoice.vat)
        nsizes.push(nstr.size)
        vat_line = [nil, tstr, nstr]
        tstr = lookandfeel.lookup(:total_brutto)
        tsizes.push(tstr.size)
        nstr = sprintf("%3.2f", invoice.total_brutto)
        nsizes.push(nstr.size)
        brutto_line = [nil, tstr, nstr]

        sizes = [qsizes.max, tsizes.max, nsizes.max]

        width = sizes.inject(7) { |a, b| a + b }

        dline = "=" * width
        sline = "-" * width

        lines.push(dline)
        lines += downloads.collect { |data|
          format_line(sizes, data)
        }
        lines.push(sline)
        lines.push(format_line(sizes, netto_line))
        lines.push(sline)
        lines.push(format_line(sizes, vat_line))
        lines.push(dline)
        lines.push(format_line(sizes, brutto_line))
        lines.push(dline)
        lines.push(nil)
        lines.join("\n")
      end

      def self.format_line(sizes, data)
        sprintf("%#{sizes.at(0)}s %-#{sizes.at(1)}s  CHF %#{sizes.at(2)}s",
          *data)
      end

      def self.yus(recipient, key)
        $oddb.yus_get_preference(recipient, key)
      end
    end
  end
end
