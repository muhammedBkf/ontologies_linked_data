require_relative "./test_ontology_common"
require "logger"

class TestInstances < LinkedData::TestOntologyCommon

  PROP_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  PROP_CLINICAL_MANIFESTATION = "http://www.owl-ontologies.com/OntologyXCT.owl#isClinicalManifestationOf"
  PROP_OBSERVABLE_TRAIT = "http://www.owl-ontologies.com/OntologyXCT.owl#isObservableTraitof"
  PROP_HAS_OCCURRENCE = "http://www.owl-ontologies.com/OntologyXCT.owl#hasOccurrenceIn"

  def self.before_suite
    LinkedData::TestCase.backend_4s_delete
  end

  def test_instance_counts_by_class
    submission_parse("TESTINST", "Testing instances",
                     "test/data/ontology_files/XCTontologyvtemp2_vvtemp2.zip",
                     12,
                     masterFileName: "XCTontologyvtemp2/XCTontologyvtemp2.owl",
                     process_rdf: true, index_search: false,
                     run_metrics: false, reasoning: true)
    submission_id = LinkedData::Models::OntologySubmission.all.first.id
    class_id = RDF::URI.new("http://www.owl-ontologies.com/OntologyXCT.owl#ClinicalManifestation")

    instances = LinkedData::InstanceLoader.get_instances_by_class(submission_id, class_id)
    assert_equal 385, instances.length

    count = LinkedData::InstanceLoader.count_instances_by_class(submission_id, class_id)
    assert_equal 385, count
  end

  def test_instance_labels
    submission_parse("TESTINST", "Testing instances",
                     "test/data/ontology_files/XCTontologyvtemp2_vvtemp2.zip",
                     12,
                     masterFileName: "XCTontologyvtemp2/XCTontologyvtemp2.owl",
                     process_rdf: true, index_search: false,
                     run_metrics: false, reasoning: true)
    submission_id = LinkedData::Models::OntologySubmission.all.first.id
    class_id = RDF::URI.new("http://www.owl-ontologies.com/OntologyXCT.owl#ClinicalManifestation")

    instances = LinkedData::InstanceLoader.get_instances_by_class(submission_id, class_id)    
    instances.each do |inst|
      assert (not inst.label.nil?)
      assert (not inst.id.nil?)
    end

    inst1 = instances.find {|inst| inst.id.to_s == 'http://www.owl-ontologies.com/OntologyXCT.owl#PresenceofAbnormalFacialShapeAt46'}
    assert (not inst1.nil?)
    assert_equal 'PresenceofAbnormalFacialShapeAt46', inst1.label

    inst2 = instances.find {|inst| inst.id.to_s == 'http://www.owl-ontologies.com/OntologyXCT.owl#PresenceofGaitDisturbanceAt50'}
    assert (not inst2.nil?)
    assert_equal 'PresenceofGaitDisturbanceAt50', inst2.label
  end

  def test_instance_properties
    known_properties = [PROP_TYPE, PROP_CLINICAL_MANIFESTATION, PROP_OBSERVABLE_TRAIT, PROP_HAS_OCCURRENCE]

    submission_parse("TESTINST", "Testing instances",
                     "test/data/ontology_files/XCTontologyvtemp2_vvtemp2.zip",
                     12,
                     masterFileName: "XCTontologyvtemp2/XCTontologyvtemp2.owl",
                     process_rdf: true, index_search: false,
                     run_metrics: false, reasoning: true)
    submission_id = LinkedData::Models::OntologySubmission.all.first.id
    class_id = RDF::URI.new("http://www.owl-ontologies.com/OntologyXCT.owl#ClinicalManifestation")

    instances = LinkedData::InstanceLoader.get_instances_by_class(submission_id, class_id)
    inst = instances.find {|inst| inst.id.to_s == 'http://www.owl-ontologies.com/OntologyXCT.owl#PresenceofThyroidNoduleAt46'}
    assert (not inst.nil?)
    assert_equal 4, inst.properties.length
    assert_equal known_properties.sort, inst.properties.keys.sort

    props = inst.properties

    known_types = [
      "http://www.owl-ontologies.com/OntologyXCT.owl#ClinicalManifestation",
      "http://www.w3.org/2002/07/owl#NamedIndividual"
    ]
    types = props[PROP_TYPE].map { |type| type.to_s }
    assert_equal 2, types.length
    assert_equal known_types.sort, types.sort

    manifestations = props[PROP_CLINICAL_MANIFESTATION] 
    assert_equal 1, manifestations.length
    assert_equal "http://www.owl-ontologies.com/OntologyXCT.owl#Patient_11_1", manifestations.first.to_s

    observables = props[PROP_OBSERVABLE_TRAIT] 
    assert_equal 1, observables.length
    assert_equal "http://www.owl-ontologies.com/OntologyXCT.owl#PresenceofThyroidNodule", observables.first.to_s

    occurrences = props[PROP_HAS_OCCURRENCE]
    assert_equal 1, occurrences.length
    assert (occurrences.first.is_a? RDF::Literal)
    assert_equal "46", occurrences.first.value
  end

end
