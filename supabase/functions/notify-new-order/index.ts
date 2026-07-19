// Supabase Edge Function: notify-new-order
//
// Called directly by the app (see lib/services/orders_repository.dart) right
// after an order + its items are saved. Looks up the store's notification
// email from `store_settings` and emails the owner via Resend.
//
// Required secret (set this in the Supabase dashboard, Edge Functions ->
// Secrets — SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are already provided
// automatically by Supabase, you don't need to set those):
//   RESEND_API_KEY   -> from https://resend.com/api-keys

import { serve } from 'https://deno.land/std@0.214.0/http/server.ts';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  try {
    const { order, items } = await req.json();

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const resendKey = Deno.env.get('RESEND_API_KEY');

    if (!supabaseUrl || !serviceKey || !resendKey) {
      return new Response(
        JSON.stringify({ error: 'Missing SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY / RESEND_API_KEY' }),
        { status: 500, headers: CORS_HEADERS },
      );
    }

    // Look up the notification email the admin set from the dashboard.
    const settingsRes = await fetch(
      `${supabaseUrl}/rest/v1/store_settings?id=eq.1&select=notification_email`,
      { headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}` } },
    );
    const settingsRows = await settingsRes.json();
    const to = settingsRows?.[0]?.notification_email;

    if (!to) {
      // No email configured yet — skip quietly, don't fail the order.
      return new Response(JSON.stringify({ skipped: 'no notification_email set' }), {
        status: 200,
        headers: CORS_HEADERS,
      });
    }

    const itemsHtml = (items ?? [])
      .map((i: { quantity: number; product_name: string; unit_price: number }) =>
        `<li>${i.quantity} × ${i.product_name} — ${i.unit_price.toFixed(2)} EGP</li>`)
      .join('');

    const emailRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${resendKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        // Resend's shared test sender — works immediately, no domain setup.
        // Swap this for an address on your own verified domain later.
        from: "Aya's Graphique <onboarding@resend.dev>",
        to: [to],
        subject: `New order from ${order.full_name}`,
        html: `
          <h2>New order — ${order.full_name}</h2>
          <p><b>Email:</b> ${order.email}<br/>
             <b>Phone:</b> ${order.phone_1 ?? ''}${order.phone_2 ? ` / ${order.phone_2}` : ''}<br/>
             <b>Address:</b> ${order.address}<br/>
             <b>Payment:</b> ${
               order.payment_method === 'instapay' ? 'InstaPay' :
               order.payment_method === 'vodafone_cash' ? 'Vodafone Cash' :
               order.payment_method === 'transfer' ? 'Vodafone Cash / InstaPay transfer' :
               'Cash on delivery'
             }${
               order.payment_sender_info
                 ? `<br/><b>${order.payment_method === 'instapay' ? 'Paid from (InstaPay name)' : 'Paid from (Vodafone Cash number)'}:</b> ${order.payment_sender_info}`
                 : ''
             }</p>
          <ul>${itemsHtml}</ul>
          <p>
            Subtotal: ${Number(order.subtotal).toFixed(2)} EGP<br/>
            Shipping: ${Number(order.shipping).toFixed(2)} EGP<br/>
            <b>Total: ${Number(order.total).toFixed(2)} EGP</b>
          </p>
        `,
      }),
    });

    if (!emailRes.ok) {
      const text = await emailRes.text();
      return new Response(JSON.stringify({ error: text }), { status: 502, headers: CORS_HEADERS });
    }

    return new Response(JSON.stringify({ sent: true }), { status: 200, headers: CORS_HEADERS });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500, headers: CORS_HEADERS });
  }
});
