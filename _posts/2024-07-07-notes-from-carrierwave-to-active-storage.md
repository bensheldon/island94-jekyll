---
title: "Notes from Carrierwave to Active Storage"
date: 2024-07-07 20:04 PDT
published: true
tags: [Rails]
---

I recently migrated [Day of the Shirt](https://dayoftheshirt.com), my graphic t-shirt sale aggregator, from storing image attachments with Carrierwave to Active Storage. It went ok! 👍

There were a couple of things driving this migration, though Carrierwave had served me very well for nearly a decade:

- For budgetary reasons, I was moving the storage service from S3 to Digital Ocean Spaces. I knew I’d be doing some sort of data migration regardless.
- I was using some monkeypatches of Carrierwave v2 that weren’t compatible with Carrierwave v3. So I knew I’d have to dig into the internals anyways if I wanted to stay up to date.
- I generally trust Rails, and by extension Active Storage, to be reliable stewards when I take them on as a dependency.

And I had a couple of requirements to work though, largely motivated because images in Day of the Shirt _are the content_ with dozens or hundreds displayed on a single page: 

- For budget (slash performance), I need to link directly to image assets. No proxying or redirecting through the Rails app.
- For SEO, I need to customize the image filenames so they are relevant to the content.
- For performance (slash availability), I need to pre-process image transformations (convert, scale, crop) before they are published. Dozens of new designs can go up on the homepage at once.
- For availability, I need to validate that the images are (1) transformable and (2) actually transformed before they are published; invalid or missing images are unacceptable. 

How’d it go? Great! 🎉 I am now fully switched over to Active Storage. It’s working really well and I was able to meet all of my requirements. Active Storage is very nice, as nice as Carrierwave.

But the errata? Yes, that’s why I’m writing the blog post, and probably why you’re reading. To document all of the stuff I did that wasn’t in the [very excellent Active Storage Rails Guide.](https://edgeguides.rubyonrails.org/active_storage_overview.html) Let’s go through it:

**Direct Linking to images** is possible via the method described in this excellent post from Florin Lipan: [“Serving Active Storage uploads through a CDN with Rails direct routes”](https://lipanski.com/posts/activestorage-cdn-rails-direct-route). 

**Customizing Active Storage filenames** is possible with a monkeypatch (maybe [someday it will be possible directly](https://github.com/rails/rails/pull/41004)). The patch simply adds the specified filename to the end of what otherwise would be a random string; and it seems durable through variants such that the variant extensions will be updated properly when the format is transformed (e.g. from a `.png` to a `.jpg`):

```ruby
# config/initializers/active_storage.rb
module MonkeypatchBlobKey
  def key
    # => hhw3kzc7wcqyglwi7alno9o5yf2v/the-image-filename.png
    self[:key] ||= File.join(self.class.generate_unique_secure_token(length: ActiveStorage::Blob::MINIMUM_TOKEN_LENGTH), filename.to_s)
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::Blob.prepend MonkeypatchBlobKey
end
```

**Preprocessing variants** required tapping into some private methods to get the variant names back out of the system. Here’s an example of processing all of the variants when the attachment changes. Beware: attachments happen in an `after_commit`, [which is good](https://www.youtube.com/live/78HzHhMnhHY), but means that I had to introduce a `published` state to the record to ensure it was not visible until the variants were processed (there is a [`preprocessed:`](https://github.com/rails/rails/pull/47473) option to process individual variants async in a background job but that, unfortunately, doesn’t meet my needs for synchronizing them all at once):

```ruby

class Shirt < ApplicationRecord
  has_one_attached :graphic do |attachable|
    attachable.variant :full, format: :jpg
    attachable.variant :large, resize_to_limit: [1024, 1024], format: :jpg
    attachable.variant :square, resize_to_fill: [300, 300], format: :jpg
    attachable.variant :thumb, resize_to_fill: [100, 100], format: :jpg
  end

  after_commit :process_graphic_variants_and_publish, if: -> (shirt){ shirt.graphic&.blob&.saved_changes? }, on: [:create, :update]

  def process_graphic_variants
    attachment_variants(:graphic).each do |variant|
      graphic.variant(variant).processed
    end
    update(published: true)
  end

  # All of the named variants for an attachment
  # @param attachment [Symbol] the name of the attachment
  # @return Array[Symbol] the names of the variants
  def attachment_variants(attachment)
    send(attachment).attachment.send(:named_variants).keys
  end
end
```

**Validating variants** was easy with a very nice and well-named gem: [`active_storage_validations`](https://github.com/igorkasyanchuk/active_storage_validations). It [works really well](https://github.com/igorkasyanchuk/active_storage_validations/blob/ab27760ecee7498e8fcb2a6434157c8cdd81038d/lib/active_storage_validations/metadata.rb#L122). 

**You will have N+1s**, where you forget to add `with_attached_*` scopes to some queries. Unfortunately Active Storage’s schema is laid out in a way that it will emit queries to the same model/table _even when it’s loading correctly_, so you may get [detection false positives](https://github.com/flyerhzm/bullet/issues/474) too. You can see that clearly in the next example with the doubly-nested `blob` association. 

**Active Storage’s schema is a beast**. I get that it’s gone through a lot of changes, and Named Variants are an amazing hack when you see how they’ve been implemented. And it’s wild. You can see that by how the [scope for `with_attached_*`](https://github.com/rails/rails/blob/9f178ada796a89c01f952fc05810b58b6f8682fc/activestorage/lib/active_storage/attached/model.rb#L129-L137) is generated:

```ruby
includes("#{name}_attachment": { blob: {
  variant_records: { image_attachment: :blob },
  preview_image_attachment: { blob: { variant_records: { image_attachment: :blob } } }
} })
```

I originally thought that when eager-loading through an association (e.g. `Merchant.includes(:shirts)`) I’d have to do something like this (🫠):

```ruby
Merchant.includes(shirts: { blob: {
  variant_records: { image_attachment: :blob },
  preview_image_attachment: { blob: { variant_records: { image_attachment: :blob } } })
```

…but fortunately this seems to work too (💅):

```ruby
Merchant.includes(:shirts).merge(Shirt.with_attached_graphic)
```

That’s everything. All in all I’m very happy with the migration 🌅
