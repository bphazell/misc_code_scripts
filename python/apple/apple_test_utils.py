
CONF_THRESHOLD = '0.75'

PROJECT = 'matching'

PROJECT_SPEC = {
	'matching': {
		'conf' : 'are_these_two_records_fundamentally_about_the_same_entity:confidence',
		'label': 'are_these_two_records_fundamentally_about_the_same_entity',
		'class': {
			'same' : 'They are the same entity',
			'different' : 'They are two different entities',
			'unknown' : 'I cannot decide (please try your best before selecting this answer)',
		}
	},
	'containment': {
		'conf' : 'relationship_between_records:confidence',
		'label': 'relationship_between_records',
		'class': {
				'parent_child' : 'A contains B',
				'child_parent' : 'B contains A',
				'siblings' : 'Both A and B are contained in something else',
				'same' : 'Both A and B are the same entity',
				'unrelated' : 'No relationship between A and B',
				'unknown' : 'I cannot decide (please try your best before selecting this answer)'
		}
	}
}

CONF_COL = PROJECT_SPEC[PROJECT]['conf']
