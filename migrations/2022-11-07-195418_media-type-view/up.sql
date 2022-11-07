create view mb_views.nft_tokens_with_media_type as
select
	*,
	reference_blob->>'animation_url' as forever_media_url,
	reference_blob->>'animation_url_type' as forever_media_type
from
	mb_views.nft_tokens;
